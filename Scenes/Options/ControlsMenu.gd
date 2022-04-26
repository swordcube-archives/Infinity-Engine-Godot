extends Node2D

var curSelected = 0

var changing_bind = false

var key_count = 4

var strums = null

func _ready():
	strums = load("res://Scenes/Strums/" + str(key_count) + "Key.tscn").instance()
	strums.name = "Strums"
	strums.global_position = Vector2(472, 360)
	add_child(strums)
	
	move_child(strums, 1)
	
	var index = 0
	for strum in strums.get_children():
		var key = $KeyTemplate.duplicate()
		key.visible = true
		key.text = Options.get_data("keybinds_" + str(key_count))[index]
		
		var fuck = 30
		
		key.rect_position.x = strum.global_position.x - fuck
		key.rect_position.y = strum.global_position.y - fuck
		$Keybinds.add_child(key)
		
		index += 1
		
	change_selection(0)
		
func _process(delta):
	$CurrentKeycount.text = "Current Keycount: " + str(key_count) + "\nPress SHIFT + LEFT/RIGHT to change the keycount"
	
	if Input.is_action_just_pressed("ui_back"):
		SceneManager.switch_scene("Options/OptionsMenu", false)
		
	if not changing_bind:
		if Input.is_action_pressed("ui_shift"):
			if Input.is_action_just_pressed("ui_left"):
				change_keycount(-1)
				
			if Input.is_action_just_pressed("ui_right"):
				change_keycount(1)
		else:
			if Input.is_action_just_pressed("ui_left"):
				change_selection(-1)
				
			if Input.is_action_just_pressed("ui_right"):
				change_selection(1)
			
		if Input.is_action_just_pressed("ui_accept"):
			changing_bind = true
			$SelectedArrow.text = "Press any key to change the " + Gameplay.note_directions[key_count - 1][curSelected] + " bind to."
			
func change_keycount(amount):
	curSelected = 0
	
	key_count += amount
	
	if key_count < 1:
		key_count = 1
		
	if key_count > 9:
		key_count = 9
		
	remove_child(strums)
	strums = load("res://Scenes/Strums/" + str(key_count) + "Key.tscn").instance()
	strums.name = "Strums"
	strums.global_position = Vector2(472, 360)
	add_child(strums)
	
	move_child(strums, 1)
	
	for keybind in $Keybinds.get_children():
		keybind.queue_free()
	
	var index = 0
	for strum in strums.get_children():
		var key = $KeyTemplate.duplicate()
		key.visible = true
		key.text = Options.get_data("keybinds_" + str(key_count))[index]
		key.rect_scale = strums.scale * 1.4
		
		var fuck = 45 * strums.scale.x
		var fuck2 = 45 * strums.scale.y
		
		key.rect_position.x = strum.global_position.x - fuck
		key.rect_position.y = strum.global_position.y - fuck2
		$Keybinds.add_child(key)
		
		index += 1
		
	change_selection(0)
			
func _input(event):
	if event is InputEventKey and event.pressed and changing_bind:
		if event.scancode == KEY_ESCAPE:
			changing_bind = false
			change_selection(0)
		else:
			var binds = Options.get_data("keybinds_" + str(key_count))
			var piss = OS.get_scancode_string(event.scancode).to_upper()
			
			binds[curSelected] = piss
			
			Options.set_data("keybinds_" + str(key_count), binds)
			
			changing_bind = false
			change_selection(0)
			
			$Keybinds.get_children()[curSelected].text = piss
			
			Keybinds.setup_Binds()
			
			AudioHandler.play_audio("confirmMenu")
	
func change_selection(amount):
	AudioHandler.play_audio("scrollMenu")
	
	curSelected += amount
	if curSelected < 0:
		curSelected = strums.get_child_count() - 1
	if curSelected > strums.get_child_count() - 1:
		curSelected = 0
		
	var index = 0
	for strum in strums.get_children():
		strum.modulate.a = 0.6
		strum.scale = Vector2(1, 1)
		
		if curSelected == index:
			strum.modulate.a = 1
			strum.scale = Vector2(1.1, 1.1)
		
		index += 1
		
	$SelectedArrow.text = "Selected Bind: " + Gameplay.note_directions[key_count - 1][curSelected]
