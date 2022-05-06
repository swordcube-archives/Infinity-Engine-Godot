extends Node

var skip_title:bool = false
var key_count:int = 4
var song_multiplier:float = 1.0

var scroll_speed:float = 1.0

var SONG = CoolUtil.get_json(Paths.song_json("Test"))

var note_types = {}

func _ready():
	reload_note_types()
	
	if get_tree().current_scene.name != "TitleScreen":
		skip_title = true
		
var ui_skin:Node = null

func reload_note_types():
	note_types.clear()
	
	var shit:Array = CoolUtil.list_files_in_directory("res://Scenes/Notes/")
	
	if "Warning" in shit:
		shit.erase("Warning")
		shit.insert(0, "Warning")
		
	if "Death" in shit:
		shit.erase("Death")
		shit.insert(0, "Death")
		
	if "Default" in shit:
		shit.erase("Default")
		shit.insert(0, "Default")
	
	for file in shit:
		if not "." in file:
			note_types[file] = load("res://Scenes/Notes/" + file + "/Note.tscn").instance()

func load_ui_skin():
	if "ui_Skin" in SONG.song:
		if ResourceLoader.exists(Paths.ui_skin(SONG.song["ui_Skin"])):
			ui_skin = load(Paths.ui_skin(SONG.song["ui_Skin"])).instance()
			ui_skin.name = SONG.song["ui_Skin"]
		else:
			var skin = Options.get_data("ui-skin")
			ui_skin = load(Paths.ui_skin(skin)).instance()
			ui_skin.name = skin
	else:
		var skin = Options.get_data("ui-skin")
		ui_skin = load(Paths.ui_skin(skin)).instance()
		ui_skin.name = skin