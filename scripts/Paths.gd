extends Node

func songJSON(song:String, diff:String = "normal"):
	return "res://assets/songs/" + song.to_lower() + "/" + diff + ".json"
	
func inst(song:String):
	return "res://assets/songs/" + song.to_lower() + "/Inst.ogg"
	
func voices(song:String):
	return "res://assets/songs/" + song.to_lower() + "/Voices.ogg"
	
func healthIcon(icon:String):
	return "res://assets/images/icons/" + icon + ".png"
	
func sound(sound:String):
	return "res://assets/sounds/" + sound + ".ogg"
	
func txt(txt:String):
	return "res://assets/" + txt + ".txt"
