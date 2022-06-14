extends Node

var downScroll:bool = true
var scrollSpeed:float = 4.0

var SONG = CoolUtil.getJSON(Paths.songJSON("stress", "hard"))

var songMultiplier:float = 1.0

var currentUiSkin:Node

func getSkin():
	if "uiSkin" in SONG.song:
		var skinPath:String = "res://assets/images/ui/skins/" + SONG.song["uiSkin"].to_lower() + "/skin.tscn"
		if ResourceLoader.exists(skinPath):
			currentUiSkin = load(skinPath).instance()
		else:
			var a:String = "res://assets/images/ui/skins/" + Preferences.getOption("ui-skin").to_lower() + "/skin.tscn"
			currentUiSkin = load(a).instance()
	else:
		var b:String = "res://assets/images/ui/skins/" + Preferences.getOption("ui-skin").to_lower() + "/skin.tscn"
		currentUiSkin = load(b).instance()
