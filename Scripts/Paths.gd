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
	
func song_path(name):
	return "res://Assets/Songs/" + name
	
func inst(music_path):
	return "res://Assets/Songs/" + music_path + "/Inst.ogg"
	
func voices(music_path):
	return "res://Assets/Songs/" + music_path + "/Voices.ogg"
	
func sound(sound_path):
	return "res://Assets/Sounds/" + sound_path + ".ogg" 