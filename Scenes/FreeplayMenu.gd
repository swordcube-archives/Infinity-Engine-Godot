extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("ui_back"):
		SceneManager.transition_to_scene("MainMenu")
