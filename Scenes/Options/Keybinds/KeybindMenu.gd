extends Node2D

var keycount:int = 4

var strum_set:Dictionary = {
	"1": load("res://Scenes/Strums/1Key.tscn").instance(),
	"2": load("res://Scenes/Strums/2Key.tscn").instance(),
	"3": load("res://Scenes/Strums/3Key.tscn").instance(),
	"4": load("res://Scenes/Strums/4Key.tscn").instance(),
	"5": load("res://Scenes/Strums/5Key.tscn").instance(),
	"6": load("res://Scenes/Strums/6Key.tscn").instance(),
	"7": load("res://Scenes/Strums/7Key.tscn").instance(),
	"8": load("res://Scenes/Strums/8Key.tscn").instance(),
	"9": load("res://Scenes/Strums/9Key.tscn").instance(),
}

onready var keybinds:Dictionary = {
	"1": Options.get_data("keybinds_1"),
	"2": Options.get_data("keybinds_2"),
	"3": Options.get_data("keybinds_3"),
	"4": Options.get_data("keybinds_4"),
	"5": Options.get_data("keybinds_5"),
	"6": Options.get_data("keybinds_6"),
	"7": Options.get_data("keybinds_7"),
	"8": Options.get_data("keybinds_8"),
	"9": Options.get_data("keybinds_9"),
}

onready var bg = $BG
onready var label = $Label

var strums:Node2D

onready var tween = $Tween
var bg_tween = Tween.new()

var cur_selected:int = 0

var setting_bind:bool = false

var can_set_binds:bool = false

func show():
	cur_selected = 0
	die = false
	
	can_set_binds = false
	
	bg.modulate.a = 0
	
	remove_child(strums)
	strums = strum_set[str(keycount)]
	strums.global_position = Vector2(CoolUtil.screen_res.x / 2, CoolUtil.screen_res.y / 2)
	add_child(strums)
	
	change_selection()
	
	tween.stop_all()
	var index:int = 0
	for obj in strums.get_children():
		obj.modulate.a = 0
		obj.label.visible = true
		obj.label.text = keybinds[str(keycount)][index]
		if cur_selected == index:
			tween.interpolate_property(obj, "modulate:a", 0, 1, 0.5, Tween.TRANS_CIRC, Tween.EASE_OUT, 0.3 * index)
		else:
			tween.interpolate_property(obj, "modulate:a", 0, 0.6, 0.5, Tween.TRANS_CIRC, Tween.EASE_OUT, 0.3 * index)
			
		tween.interpolate_property(obj, "position:y", obj.position.y - 10, obj.position.y, 0.5, Tween.TRANS_CIRC, Tween.EASE_OUT, 0.3 * index)
		index += 1
		
	tween.start()
	
	yield(get_tree().create_timer(0.1), "timeout")
	can_set_binds = true
	
func change_selection(amount:int = 0):
	cur_selected += amount
	if cur_selected < 0:
		cur_selected = strums.get_child_count() - 1
	if cur_selected > strums.get_child_count() - 1:
		cur_selected = 0
		
	var index:int = 0
	for strum in strums.get_children():
		if cur_selected == index:
			strum.scale = Vector2(1.2, 1.2)
			strum.modulate.a = 1
		else:
			strum.scale = Vector2.ONE
			strum.modulate.a = 0.6
			
		index += 1
		
	AudioHandler.play_audio("scrollMenu")
	
func _physics_process(delta):
	if die:
		bg.modulate.a = lerp(bg.modulate.a, 0, delta * 7)
	else:
		bg.modulate.a = lerp(bg.modulate.a, 1, delta * 7)
		
	if setting_bind:
		label.text = "Press any key to change the selected keybind."
	else:
		label.text = "Press LEFT or RIGHT to select an arrow to modify."
	
var die:bool = false

func _process(delta):
	if not setting_bind:
		if not die and Input.is_action_just_pressed("ui_back"):
			remove_child(strums)
			
			AudioHandler.play_audio("cancelMenu")
			die = true
			
		if die and bg.modulate.a <= 0.2:
			die = false
			visible = false
			
			
		if visible and Input.is_action_just_pressed("ui_left"):
			change_selection(-1)
			
		if visible and Input.is_action_just_pressed("ui_right"):
			change_selection(1)
		
	if can_set_binds and visible and Input.is_action_just_pressed("ui_accept"):
		if not setting_bind:
			setting_bind = true
			
func _input(event):
	if event is InputEventKey and event.pressed and setting_bind:
		if event.scancode == KEY_ESCAPE:
			setting_bind = false
			change_selection()
		else:
			var binds = Options.get_data("keybinds_" + str(keycount))
			var piss = OS.get_scancode_string(event.scancode).to_upper()
			
			binds[cur_selected] = piss
			
			Options.set_data("keybinds_" + str(keycount), binds)
			
			setting_bind = false
			change_selection()
			
			strums.get_child(cur_selected).label.text = piss
			
			Keybinds.setup_Binds()
			
			AudioHandler.play_audio("confirmMenu")
