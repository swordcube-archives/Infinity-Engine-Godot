extends Node

func switchScene(scene:String):
	get_tree().change_scene("res://scenes/" + scene + ".tscn")
