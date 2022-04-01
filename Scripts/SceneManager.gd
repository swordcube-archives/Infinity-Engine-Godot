extends Node

func switch_scene(scene):
	get_tree().change_scene("res://Scenes/" + scene + ".tscn")

func transition_to_scene(scene):
	print("SWITCHING TO " + scene)
	switch_scene(scene)
