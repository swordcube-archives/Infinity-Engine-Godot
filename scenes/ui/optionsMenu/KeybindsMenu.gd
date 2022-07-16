extends Node2D

var keySelected:int = 0
var keyCount:int = 4
var strums:Node2D

func _ready():
	PlayStateSettings.getSkin()
	get_tree().paused = true
	strums = load("res://scenes/ui/strums/"+str(keyCount)+"K.tscn").instance()
	strums.position = Vector2(CoolUtil.screenWidth/2, CoolUtil.screenHeight/2)
	add_child(strums)
	var i:int = 0
	for strum in strums.get_children():
		strum.hasInput = false
		strum.keybind.text = Preferences.getOption("binds_"+str(keyCount))[i]
		strum.keybind.visible = true
		i += 1
	
var selectingKey:bool = false
	
func _input(event):
	if not visible: return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		if selectingKey: return
		var i:int = 0
		for strum in strums.get_children():
			var arrowSize:float = 50.0
			if event.position.x > strum.global_position.x - arrowSize and event.position.x < strum.global_position.x + arrowSize and event.position.y > strum.global_position.y - arrowSize and event.position.y < strum.global_position.y + arrowSize:
				strum.modulate.a = 1
				keySelected = i
				selectingKey = true
				$Waiting.visible = true
				
				AudioHandler.playSFX("scrollMenu")
			else:
				strum.modulate.a = 0.6
			i += 1
			
	if event is InputEventKey and event.pressed and selectingKey:
		if not Input.is_action_pressed("ui_back"):
			var bindsData = Preferences.getOption("binds_" + str(keyCount))
			
			var keyData = OS.get_scancode_string(event.scancode).to_upper()	
			bindsData[keySelected] = keyData
			
			Preferences.setOption("binds_" + str(keyCount), bindsData)
			
			strums.get_child(keySelected).keybind.text = bindsData[keySelected]
			selectingKey = false
			$Waiting.visible = false
			
			Preferences.setupBinds()
			
			AudioHandler.playSFX("confirmMenu")
	
func _process(delta):
	if not visible: return
	
	if Input.is_action_just_pressed("ui_back"):
		AudioHandler.playSFX("cancelMenu")
		exit()
		
	if not selectingKey:
		for strum in strums.get_children():
			var event = get_global_mouse_position()
			var arrowSize:float = 50.0
			if event.x > strum.global_position.x - arrowSize and event.x < strum.global_position.x + arrowSize and event.y > strum.global_position.y - arrowSize and event.y < strum.global_position.y + arrowSize:
				strum.modulate.a = 1
			else:
				strum.modulate.a = 0.6
func exit():
	queue_free()
	get_tree().paused = false
