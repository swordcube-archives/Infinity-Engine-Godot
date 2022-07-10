extends Node

func loadTex(path:String):
	if ResourceLoader.exists(path):
		return load(path)
	else:
		return CoolUtil.nullImage
		
func getStoryMenuChar(character:String):
	if character == "":
		character = "blank"
		
	var path:String = "res://scenes/storymode/chars/"+character+".tscn"
	if ResourceLoader.exists(path):
		return load(path).instance()
	else:
		return load("res://scenes/storymode/chars/bf.tscn").instance()
		
func image(image:String):
	return "res://assets/images/" + image + ".png"

func song(song:String):
	return "res://assets/songs/" + song.to_lower()

func songJSON(song:String, diff:String = "normal"):
	return "res://assets/songs/" + song.to_lower() + "/" + diff + ".json"
	
func inst(song:String):
	return "res://assets/songs/" + song.to_lower() + "/Inst.ogg"
	
func voices(song:String):
	return "res://assets/songs/" + song.to_lower() + "/Voices.ogg"
	
func healthIcon(icon:String):
	var path:String = "res://assets/images/icons/" + icon + ".png"
	if ResourceLoader.exists(path):
		return path
		
	return "res://assets/images/icons/face.png"
	
func sound(sound:String):
	return "res://assets/sounds/" + sound + ".ogg"
	
func txt(txt:String):
	return "res://assets/" + txt + ".txt"
	
func character(character:String):
	return "res://scenes/chars/" + character + ".tscn"
	
func getCharScene(characterToGet:String):
	if ResourceLoader.exists(character(characterToGet)):
		return load(character(characterToGet)).instance()
		
	return load(character("bf")).instance()
	
func stage(stage:String):
	return "res://scenes/stages/" + stage + ".tscn"
	
func getStageScene(stageToGet:String):
	if ResourceLoader.exists(stage(stageToGet)):
		return load(stage(stageToGet)).instance()
		
	return load(stage("stage")).instance()
