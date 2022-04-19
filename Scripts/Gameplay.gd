extends Node

onready var SONG = JsonUtil.get_json("res://Assets/Songs/Tutorial/hard")
var ui_Skin = "Default"

var death_character = "bf-dead"

var death_camera_pos = Vector2(0, 0)
var death_character_pos = Vector2(0, 0)

var blueballed:int = 0

var used_practice:bool = false

var story_mode:bool = false
var story_score:int = 0
var story_playlist = []

var difficulty:String = "normal"
var week_name:String = "week1"

var song_multiplier:float = 1.0

var scroll_speed:float = 1.0

var key_count:int = 4

var note_directions = [ # goes from 1 - 9k
	["SPACE"],
	["LEFT", "RIGHT"],
	["LEFT", "SPACE", "RIGHT"],
	["LEFT", "DOWN", "UP", "RIGHT"],
	["LEFT", "DOWN", "SPACE", "UP", "RIGHT"],
	["LEFT", "DOWN", "RIGHT", "LEFT", "UP", "RIGHT"],
	["LEFT", "DOWN", "RIGHT", "SPACE", "LEFT", "UP", "RIGHT"],
	["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
	["LEFT", "DOWN", "UP", "RIGHT", "SPACE", "LEFT", "DOWN", "UP", "RIGHT"],
]

var note_letter_directions = [ # goes from 1 - 9k
	["E"],
	["A", "D"],
	["A", "E", "D"],
	["A", "B", "C", "D"],
	["A", "B", "E", "C", "D"],
	["A", "B", "D", "F", "C", "I"],
	["A", "B", "D", "E", "F", "C", "I"],
	["A", "B", "C", "D", "F", "G", "H", "I"],
	["A", "B", "C", "D", "E", "F", "G", "H", "I"],
]

func _ready():
	initialize_shit()
	
	print("Current OS: " + OS.get_name())

func _process(delta):
	if SONG != null and "ui_Skin" in SONG.song:
		ui_Skin = SONG.song.ui_Skin
	else:
		ui_Skin = Options.get_data("ui-skin")
		
	if "keyCount" in Gameplay.SONG.song:
		key_count = Gameplay.SONG.song.keyCount
		
var skipped_title = false

func initialize_shit():
	if get_tree().current_scene.name != "TitleScreen":
		skipped_title = true
