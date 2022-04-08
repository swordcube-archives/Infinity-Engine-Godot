extends Node

var SONG = JsonUtil.get_json("res://Assets/Songs/Tutorial/hard")
var ui_Skin = "Default"

var story_mode:bool = false
var story_score:int = 0
var story_playlist = []

var difficulty:String = "normal"
var week_name:String = "week1"

var song_multiplier:float = 1.0

func _process(delta):
	if SONG != null and "ui_Skin" in SONG.song:
		ui_Skin = SONG.song.ui_Skin
	else:
		ui_Skin = Options.get_data("ui-skin")
