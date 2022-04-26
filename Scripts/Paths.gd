extends Node

func image(image_path, custom_path = false, string_only = false):
	var image
	
	# this is so if you wanna type in "Image.png", you can!
	image_path = image_path.split(".png")[0]
	
	if not string_only:
		if custom_path:
			image = load("res://Assets/" + image_path + ".png")
		else:
			image = load("res://Assets/Images/" + image_path + ".png")
			
		return image
	else:
		if custom_path:
			return "res://Assets/" + image_path + ".png"
		else:
			return "res://Assets/Images/" + image_path + ".png"
			
	return null
	
func music(music_path):
	return "res://Assets/Music/" + music_path + ".ogg" 
	
func song_path(name, difficulty = ""):
	if difficulty == "":
		return "res://Assets/Songs/" + name
	else:
		return "res://Assets/Songs/" + name + "/" + difficulty.to_lower()
	
func txt(txt_path, custom_path = false):
	if custom_path:
		return "res://" + txt_path + ".txt"
	else:
		return "res://Assets/" + txt_path + ".txt"
		
	return null
	
func json(txt_path, custom_path = false):
	if custom_path:
		return "res://" + txt_path + ".json"
	else:
		return "res://Assets/" + txt_path + ".json"
		
	return null
	
func inst(music_path):
	return "res://Assets/Songs/" + music_path + "/Inst.ogg"
	
func voices(music_path):
	return "res://Assets/Songs/" + music_path + "/Voices.ogg"
	
func sound(sound_path):
	return "res://Assets/Sounds/" + sound_path + ".ogg"
	
func stage(stage):
	return "res://Stages/" + stage + "/stage.tscn"
	
func scene(scene):
	return "res://Scenes/" + scene + ".tscn"
	
func character(character):
	return "res://Characters/" + character + "/char.tscn"
