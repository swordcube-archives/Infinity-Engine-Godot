extends Node

func json(file):
	return "res://Assets/Data/" + file + ".json"
	
func icon_path(icon):
	return "res://Assets/Images/Icons/" + icon + ".png"
	
func txt(file):
	return "res://Assets/" + file + ".txt"
	
func week_json(week_name):
	return "res://Assets/Weeks/" + week_name + ".json"
