extends Node

var availableDifficulties:Array = [
	"easy",
	"normal",
	"hard"
]

var storyScore:int = 0
var storyMode:bool = false
var storyWeekName:String = "tutorial"
var storyPlaylist:Array = []

var usedPractice:bool = false
var practiceMode:bool = false

var difficulty:String = "normal"
var deaths:int = 0

var downScroll:bool = true
var botPlay:bool = false

var scrollSpeed:float = 4.0

var goBackToOptionsFromPause:bool = false

var SONG = CoolUtil.getJSON(Paths.songJSON("test", difficulty))

var songMultiplier:float = 1.0

var currentUiSkin:Node

var deathCharacter:String = "bf-dead"
var deathPosition:Vector2 = Vector2.ZERO
var deathCamPosition:Vector2 = Vector2.ZERO
var deathCamZoom:Vector2 = Vector2.ZERO

func _ready():
	makeSongSettingsReal()

func _process(delta):
	makeSongSettingsReal()
		
func makeSongSettingsReal():
	if not "gf" in SONG.song:
		SONG.song.gf = "gf"
		
	if not "stage" in SONG.song:
		SONG.song.stage = "stage"
		
	if not "uiSkin" in SONG.song:
		SONG.song.uiSkin = ""
		
	if not "pixelStage" in SONG.song:
		SONG.song.pixelStage = false

func getSkin():
	if "uiSkin" in SONG.song and SONG.song.uiSkin != "":
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
