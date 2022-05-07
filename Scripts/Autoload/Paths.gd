extends Node

func ui_skin(skin):
	return "res://Scenes/UI Skins/" + skin + ".tscn"
	
func stage(stage):
	return "res://Scenes/Stages/" + stage + ".tscn"
	
func character(character):
	return "res://Scenes/Characters/" + character + ".tscn"

func song_json(song, diff = "normal"):
	return "res://Assets/Songs/" + song + "/" + diff + ".json"

func json(file):
	return "res://Assets/Data/" + file + ".json"
	
func icon_path(icon):
	return "res://Assets/Images/Icons/" + icon + ".png"
	
func txt(file):
	return "res://Assets/" + file + ".txt"
	
func week_json(week_name):
	return "res://Assets/Weeks/" + week_name + ".json"
