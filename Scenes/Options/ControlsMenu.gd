extends Node2D

var curSelected = 0

var changing_bind = false

var directions = ["LEFT", "DOWN", "UP", "RIGHT"]
var letter_directions = ["A", "B", "C", "D"]

func _ready():
	$Misc/Transition._fade_out()
	
	var index = 0
	for strum in $Strums.get_children():
		var key = $KeyTemplate.duplicate()
		key.visible = true
		key.text = Options.get_data("keybinds")[index]
		
		var fuck = 30
		
		key.rect_position.x = strum.global_position.x - fuck
		key.rect_position.y = strum.global_position.y - fuck
		$Keybinds.add_child(key)
		
		index += 1
		
	change_selection(0)
		
func _process(delta):
	if Input.is_action_just_pressed("ui_back"):
		$Misc/Transition.transition_to_scene("Options/OptionsMenu")
		
	if not changing_bind:
		if Input.is_action_just_pressed("ui_left"):
			change_selection(-1)
			
		if Input.is_action_just_pressed("ui_right"):
			change_selection(1)
			
		if Input.is_action_just_pressed("ui_accept"):
			changing_bind = true
			$SelectedArrow.text = "Press any key to change the " + directions[curSelected] + " bind to."
			
func _input(event):
	if event is InputEventKey and event.pressed and changing_bind:
		if event.scancode == KEY_ESCAPE:
			changing_bind = false
			change_selection(0)
		else:
			var binds = Options.get_data("keybinds")
			var piss = OS.get_scancode_string(event.scancode).to_upper()
			
			binds[curSelected] = piss
			
			Options.set_data("keybinds", binds)
			
			changing_bind = false
			change_selection(0)
			
			$Keybinds.get_children()[curSelected].text = piss
			
			Keybinds.setup_Binds()
			
			AudioHandler.play_audio("confirmMenu")
	
func change_selection(amount):
	AudioHandler.play_audio("scrollMenu")
	
	curSelected += amount
	if curSelected < 0:
		curSelected = $Strums.get_child_count() - 1
	if curSelected > $Strums.get_child_count() - 1:
		curSelected = 0
		
	var index = 0
	for strum in $Strums.get_children():
		strum.modulate.a = 0.6
		strum.scale = Vector2(1, 1)
		
		if curSelected == index:
			strum.modulate.a = 1
			strum.scale = Vector2(1.1, 1.1)
		
		index += 1
		
	$SelectedArrow.text = "Selected Bind: " + directions[curSelected]
