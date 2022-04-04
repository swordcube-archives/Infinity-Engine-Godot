extends Node

var SONG = null
var ui_Skin = "Default"

func _process(delta):
	if SONG != null and SONG.song.get("ui_Skin") != null:
		ui_Skin = SONG.song.ui_Skin
	else:
		ui_Skin = Options.get_data("ui-skin")
