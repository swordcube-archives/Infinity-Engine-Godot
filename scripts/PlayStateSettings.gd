extends Node

var downScroll:bool = true
var scrollSpeed:float = 4.0

var SONG = CoolUtil.getJSON(Paths.songJSON("test", "normal"))

var songMultiplier:float = 1.0

var currentUiSkin:Node

func getSkin():
	if "uiSkin" in SONG.song:
		var skinPath:String = "res://assets/images/ui/skins/" + SONG.song["uiSkin"].to_lower() + "/skin.tscn"
		var skinPathPixel:String = "res://assets/images/ui/skins/" + SONG.song["uiSkin"].to_lower() + "-pixel/skin.tscn"
		if "pixelStage" in SONG.song and SONG.song["pixelStage"] and ResourceLoader.exists(skinPathPixel):
			currentUiSkin = load(skinPathPixel).instance()
		elif ResourceLoader.exists(skinPath):
			currentUiSkin = load(skinPath).instance()
		else:
			var a:String = "res://assets/images/ui/skins/" + Preferences.getOption("ui-skin").to_lower() + "/skin.tscn"
			currentUiSkin = load(a).instance()
	else:
		var b:String = "res://assets/images/ui/skins/" + Preferences.getOption("ui-skin").to_lower() + "/skin.tscn"
		var bPixel:String = "res://assets/images/ui/skins/" + Preferences.getOption("ui-skin").to_lower() + "-pixel/skin.tscn"
		
		if "pixelStage" in SONG.song and SONG.song["pixelStage"] and ResourceLoader.exists(bPixel):
			currentUiSkin = load(bPixel).instance()
		else:
			currentUiSkin = load(b).instance()
