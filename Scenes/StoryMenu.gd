extends Node2D

onready var week_template = $WeekTemplate
onready var visible_weeks = $Weeks

onready var left_arrow = $Difficulty/LeftArrow
onready var right_arrow = $Difficulty/RightArrow

onready var diff = $Difficulty/Diff

onready var tracks = $Tracks/Label

onready var characters = $Characters

onready var score_text = $ScoreText
onready var week_title_text = $WeekTitleText

var dad:Node2D
var bf:Node2D
var gf:Node2D

var diff_textures:Dictionary = {}
var loaded_textures:Dictionary = {}

var loaded_characters:Dictionary = {}

var weeks:Array = []

var cur_selected:int = 0
var cur_difficulty:int = 1

var default_difficulties:Array = ["easy", "normal", "hard"]
var difficulties:Array = default_difficulties

func sort_ascending(a, b):
	if a.week_num < b.week_num:
		return true
		
	return false

func _ready():
	AudioHandler.play_music("freakyMenu")
	
	Conductor.change_bpm(102)
	Conductor.connect("beat_hit", self, "beat_hit")
	
	MobileControls.switch_to("dpad")
	
	load_diff_textures()
	
	var list = CoolUtil.list_files_in_directory("res://Scenes/Story Characters")
	for item in list:
		if not item.begins_with(".") and item.ends_with(".tscn"):
			loaded_characters[item.split(".tscn")[0]] = load("res://Scenes/Story Characters/" + item).instance()
	
	scan_weeks()
	spawn_weeks()
	
	dad.dance()
	gf.dance()
	bf.dance()
	
func load_diff_textures():
	var list = CoolUtil.list_files_in_directory("res://Assets/Images/Difficulties/")
	for item in list:
		if not item.begins_with(".") and item.ends_with(".png"):
			diff_textures[item.split(".png")[0]] = load("res://Assets/Images/Difficulties/" + item)
			
	print(diff_textures.keys())
	
func scan_weeks():
	var list = CoolUtil.list_files_in_directory("res://Assets/Weeks")
	for item in list:
		if not item.begins_with(".") and item.ends_with(".json"):
			var week_name:String = item.split(".json")[0]
			var json = CoolUtil.get_json(Paths.week_json(week_name))
			
			var shows_in_story:bool = false
			
			for song in json.songs:
				if song.shows_in_story:
					shows_in_story = true
					break
			
			if json.songs.size() > 0 and shows_in_story:
				var tex_path = "res://Assets/Images/StoryMenu/" + json.week_name + ".png"
				var tex:StreamTexture = CoolUtil.load_texture(tex_path)
				loaded_textures[week_name] = tex
				
				weeks.append(json)
			
	weeks.sort_custom(self, "sort_ascending")
	
var ready:bool = false

func _physics_process(delta):
	if ready:
		lerpScore = lerp(lerpScore, Highscores.get_week_score(weeks[cur_selected].week_name), delta * 15)
		score_text.text = "WEEK SCORE: " + str(round(lerpScore))
		
		for index in visible_weeks.get_child_count():
			var week = visible_weeks.get_child(index)
			week.global_position.y = lerp(week.global_position.y, 520 + (130 * (index - cur_selected)), delta * 10)
			
var can_move:bool = true
func _process(delta):
	if AudioHandler.freakyMenu.playing:
		Conductor.song_position = AudioHandler.freakyMenu.get_playback_position() * 1000.0
	else:
		Conductor.song_position += delta * 1000.0
		
	if can_move:
		# just pressed
		if Input.is_action_just_pressed("ui_up"):
			change_selection(-1)
			
		if Input.is_action_just_pressed("ui_down"):
			change_selection(1)
			
		if Input.is_action_just_pressed("ui_left"):
			change_difficulty(-1)
			
		if Input.is_action_just_pressed("ui_right"):
			change_difficulty(1)
			
		if Input.is_action_just_pressed("ui_accept"):
			select_week()
			
		if Input.is_action_just_pressed("ui_back"):
			AudioHandler.play_audio("cancelMenu")
			SceneHandler.switch_to("MainMenu")
			
		# pressed
		if Input.is_action_pressed("ui_left"):
			left_arrow.play("arrow push left")
		else:
			left_arrow.play("arrow left")	
			
		if Input.is_action_pressed("ui_right"):
			right_arrow.play("arrow push right")
		else:
			right_arrow.play("arrow right")
			
func select_week():
	can_move = false
	
	GameplaySettings.story_playlist = []
	
	for song in weeks[cur_selected].songs:
		var shows_in_story:bool = false
		
		for check_song in weeks[cur_selected].songs:
			if check_song.shows_in_story:
				shows_in_story = true
				break
		
		if weeks[cur_selected].songs.size() > 0 and shows_in_story:
			GameplaySettings.story_playlist.append(song.name)
			
	GameplaySettings.song_multiplier = 1
	GameplaySettings.difficulty = difficulties[cur_difficulty]
	GameplaySettings.SONG = CoolUtil.get_json(Paths.song_json(GameplaySettings.story_playlist[0], difficulties[cur_difficulty]))
		
	GameplaySettings.story_mode = true
	GameplaySettings.story_score = 0
	GameplaySettings.week_name = weeks[cur_selected].week_name
	
	bf.play_anim("confirm")
	AudioHandler.play_audio("confirmMenu")
	
	visible_weeks.get_child(cur_selected).flash()
	
	yield(get_tree().create_timer(1), "timeout")
	AudioHandler.stop_music()
	SceneHandler.switch_to("PlayState")
	
func spawn_weeks():
	for index in weeks.size():
		var week = weeks[index]
		
		var new_week = week_template.duplicate()
		new_week.global_position = Vector2(640, 500 + (50 * index))
		new_week.visible = true
		visible_weeks.add_child(new_week)
		
		new_week.change_texture(loaded_textures[week.week_name])
		
	change_selection()
		
	yield(get_tree().create_timer(0.5), "timeout")
	ready = true
	
var old_diff:int = 0
var lerpScore:float = 0

func change_difficulty(amount:int = 0):
	cur_difficulty += amount
	
	if cur_difficulty < 0:
		cur_difficulty = difficulties.size() - 1
		
	if cur_difficulty > difficulties.size() - 1:
		cur_difficulty = 0
		
	if old_diff != cur_difficulty:
		old_diff = cur_difficulty
		
		var diff_tween = $Difficulty/Tween
			
		diff_tween.stop_all()
		diff.modulate.a = 0
		diff.position.y = -10
		
		diff_tween.interpolate_property(diff, "modulate:a", diff.modulate.a, 1, 0.1)
		diff_tween.interpolate_property(diff, "position:y", diff.position.y, 0, 0.1)
		diff_tween.start()
			
		var diff_str:String = difficulties[cur_difficulty]
		diff.texture = diff_textures[diff_str]
	
func change_selection(amount:int = 0):
	cur_selected += amount
	
	if cur_selected < 0:
		cur_selected = visible_weeks.get_child_count() - 1
		
	if cur_selected > visible_weeks.get_child_count() - 1:
		cur_selected = 0
		
	for i in visible_weeks.get_child_count():
		if cur_selected == i:
			visible_weeks.get_child(i).modulate.a = 1
		else:
			visible_weeks.get_child(i).modulate.a = 0.6
			
	if "difficulties" in weeks[cur_selected]:
		difficulties = weeks[cur_selected].difficulties
	else:
		difficulties = default_difficulties
		
	tracks.text = ""
	for track in weeks[cur_selected].songs:
		var shows_in_story:bool = false
		
		for check_song in weeks[cur_selected].songs:
			if check_song.shows_in_story:
				shows_in_story = true
				break
		
		if weeks[cur_selected].songs.size() > 0 and shows_in_story:
			tracks.text += track.name + "\n"
		
	change_difficulty()
	
	load_characters()
	
	week_title_text.text = weeks[cur_selected].week_title
			
	AudioHandler.play_audio("scrollMenu")
	
var first_init:bool = true
func load_characters():
	var origin_x:float = 260
	var spacing:float = 370
		
	var swag_characters = [
		weeks[cur_selected].characters[0],
		weeks[cur_selected].characters[1],
		weeks[cur_selected].characters[2]
	]
	
	for index in swag_characters.size():
		var c = swag_characters[index]
		
		if len(c) == 0:
			swag_characters[index] = "blank"
	
	if first_init or not dad.name == swag_characters[0]:
		characters.remove_child(dad)
		dad = loaded_characters[swag_characters[0]].duplicate()
		dad.global_position = Vector2(origin_x, 450)
		dad.dance()
		characters.add_child(dad)
	
	if first_init or not bf.name == swag_characters[1]:
		characters.remove_child(bf)
		bf = loaded_characters[swag_characters[1]].duplicate()
		bf.global_position = Vector2(origin_x + (spacing * 1), 450)
		bf.dance()
		characters.add_child(bf)
	
	if first_init or not gf.name == swag_characters[2]:
		characters.remove_child(gf)
		gf = loaded_characters[swag_characters[2]].duplicate()
		gf.global_position = Vector2(origin_x + (spacing * 2), 450)
		gf.dance()
		characters.add_child(gf)
	
	first_init = false
	
func beat_hit():
	if dad and dad.is_dancing():
		dad.dance()
	if gf and gf.is_dancing():
		gf.dance()
	if bf and bf.is_dancing():
		bf.dance()
