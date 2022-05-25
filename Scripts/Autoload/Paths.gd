extends Node

func ui_skin(skin):
	return "res://Scenes/UI Skins/" + skin + ".tscn"
	
func stage(stage):
	return "res://Scenes/Stages/" + stage + ".tscn"
	
func character(character):
	return "res://Scenes/Characters/" + character + ".tscn"

func song_json(song, diff = "normal"):
	return "res://Assets/Songs/" + song + "/" + diff + ".json"
	
func song(song):
	return "res://Assets/Songs/" + song
	
func inst(song):
	return "res://Assets/Songs/" + song + "/Inst.ogg"
	
func voices(song):
	return "res://Assets/Songs/" + song + "/Voices.ogg"

func json(file):
	return "res://Assets/Data/" + file + ".json"
	
func icon_path(icon):
	return "res://Assets/Images/Icons/" + icon + ".png"
	
func txt(file):
	return "res://Assets/" + file + ".txt"
	
func week_json(week_name):
	return "res://Assets/Weeks/" + week_name + ".json"
	
func event(event):
	return "res://Scenes/Events/" + event + ".tscn"
	
func char_icon(a):
	return "res://Assets/Images/Icons/" + a + ".png"

func image(a):
	return "res://Assets/Images/" + a + ".png"

func music(a):
	return "res://Assets/Music/" + a + ".ogg"

func sound(a):
	return "res://Assets/Sounds/" + a + ".ogg"
	
func format_text_for_highscore(song):
	return song.to_lower().replace(" ", "-")
