extends Node

onready var SONG = JsonUtil.get_json(Paths.song_path("Test", "normal"))
var ui_Skin = "Default"

var ui_Skin_Scene = get_ui_skin("Default")

var death_character = "bf-dead"

var death_camera_pos = Vector2(0, 0)
var death_character_pos = Vector2(0, 0)

var blueballed:int = 0
var practice_mode:bool = false

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
	
var old_skin = "???"

func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.set_window_fullscreen(!OS.window_fullscreen)
		
	if SONG != null and "ui_Skin" in SONG.song:
		if not old_skin == SONG.song.ui_Skin:
			old_skin = SONG.song.ui_Skin
			ui_Skin = old_skin
			ui_Skin_Scene = get_ui_skin(ui_Skin)
	else:
		if not old_skin == Options.get_data("ui-skin"):
			old_skin = Options.get_data("ui-skin")
			ui_Skin = old_skin
			ui_Skin_Scene = get_ui_skin(ui_Skin)
		
	if "mania" in Gameplay.SONG.song:
		match Gameplay.SONG.song.mania:
			_:
				key_count = 4
			1:
				key_count = 6
			2:
				key_count = 7
			3:
				key_count = 9
		
	if "keyCount" in Gameplay.SONG.song:
		key_count = Gameplay.SONG.song.keyCount
		
var skipped_title = false

func initialize_shit():
	VisualServer.set_default_clear_color(Color("000000"))
	if get_tree().current_scene.name != "TitleScreen":
		skipped_title = true
		
func get_ui_skin(skin):
	var loaded_skin = load("res://Assets/Images/UI Skins/" + skin + "/Skin.tscn")
	return loaded_skin.instance()
