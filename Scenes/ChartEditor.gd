extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		SceneHandler.switch_to("PlayState")
		
	if Input.is_action_just_pressed("ui_back"):
		SceneHandler.switch_to("ToolsMenu")
