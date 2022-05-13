extends Node2D

onready var bg = $BG
onready var visible_songs = $Songs

onready var diff_bg = $DiffBG
onready var pb = $PB
onready var diff = $Diff
onready var speed = $Speed

var weeks:Array = []
var songs:Array = []

var ready:bool = false

var cur_selected:int = 0
var cur_difficulty:int = 1

var cur_speed:float = 1.0

func sort_ascending(a, b):
	if a.week_num < b.week_num:
		return true
		
	return false

func _ready():
	MobileControls.switch_to("dpad_with_shift")
	
	GameplaySettings.deaths = 0
	AudioHandler.inst.stop()
	AudioHandler.voices.stop()
	AudioHandler.play_music("freakyMenu")
	
	init_song_list()
	
func _physics_process(delta):
	position_highscore()
	
	var songName = visible_songs.get_child(cur_selected).text + "-" + visible_songs.get_child(cur_selected).difficulties[cur_difficulty]
	lerpScore = lerp(lerpScore, Highscores.get_song_score(songName), delta * 10)
	
	if ready:
		bg.modulate = lerp(bg.modulate, Color(visible_songs.get_child(cur_selected).color), delta * 2)
		var index = 0
		for song in visible_songs.get_children():
			var x = song.rect_position.x
			var y = song.rect_position.y
			song.rect_position.x = lerp(x, 95 + ((index - cur_selected) * 17), delta * 10)
			song.rect_position.y = lerp(y, 335 + ((index - cur_selected) * 155), delta * 10)
			
			index += 1
			
var lerpScore:float = 0
			
func position_highscore():
	pb.rect_size.x = 0
	pb.text = "PERSONAL BEST: " + str(abs(round(lerpScore)))
	
	speed.rect_size.x = 0
	speed.text = "Speed: " + str(CoolUtil.round_decimal(cur_speed, 2)) + " (SHIFT+R)"
	
	diff.rect_size.x = 0
	change_difficulty(0, true)
	
	diff_bg.rect_size.x = pb.rect_size.x + 5
	pb.rect_size.x += 5
	
	var fard = false
	if diff.rect_size.x > diff_bg.rect_size.x:
		fard = true
		diff_bg.rect_size.x = diff.rect_size.x + 5
		diff.rect_size.x += 5
		
	diff.rect_size.x = diff_bg.rect_size.x
	speed.rect_size.x = diff_bg.rect_size.x
	
	diff_bg.rect_position.x = 1280 - diff_bg.rect_size.x
	pb.rect_position.x = 1280 - pb.rect_size.x
	diff.rect_position.x = 1280 - diff.rect_size.x
	if fard:
		speed.rect_size.x = 0
		speed.text = "Speed: " + str(CoolUtil.round_decimal(cur_speed, 2)) + " (SHIFT+R)"
		speed.rect_position.x = 1280 - speed.rect_size.x
	else:
		speed.rect_position.x = 1280 - speed.rect_size.x
		
	if speed.rect_size.x > diff_bg.rect_size.x:
		diff_bg.rect_size.x = speed.rect_size.x + 5
		
		pb.rect_size.x = diff_bg.rect_size.x
		diff.rect_size.x = diff_bg.rect_size.x
		speed.rect_size.x = diff_bg.rect_size.x
			
		diff_bg.rect_position.x = 1280 - diff_bg.rect_size.x
		pb.rect_position.x = 1280 - diff_bg.rect_size.x
		diff.rect_position.x = 1280 - diff_bg.rect_size.x
			
var hold_timer:float = 0.0
			
func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		change_selection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		change_selection(1)
		
	if Input.is_action_pressed("ui_shift") and Input.is_action_just_pressed("reset"):
		cur_speed = 1
		AudioHandler.change_music_pitch(cur_speed)
		
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		hold_timer += delta
		if hold_timer > 0.5 or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
			if Input.is_action_pressed("ui_shift"):
				var mult:float = 0.05
				if Input.is_action_pressed("ui_left"):
					mult *= -1
				
				change_speed(mult)
			else:
				var mult:float = 1
				if Input.is_action_pressed("ui_left"):
					mult *= -1
				
				change_difficulty(mult)
	else:
		hold_timer = 0
		
	if Input.is_action_just_pressed("ui_space"):
		AudioHandler.play_inst(visible_songs.get_child(cur_selected).text)
		AudioHandler.play_voices(visible_songs.get_child(cur_selected).text)
		
		AudioHandler.inst.seek(0)
		AudioHandler.voices.seek(0)
	elif Input.is_action_just_pressed("ui_accept"):
		AudioHandler.stop_music()
		
		if not Transition.transitioning:
			GameplaySettings.story_mode = false
			GameplaySettings.SONG = CoolUtil.get_json(Paths.song_json(visible_songs.get_child(cur_selected).text, visible_songs.get_child(cur_selected).difficulties[cur_difficulty]))
			
			var diff = visible_songs.get_child(cur_selected).difficulties[cur_difficulty]
			GameplaySettings.difficulty = diff
			GameplaySettings.song_multiplier = CoolUtil.round_decimal(cur_speed, 2)
			SceneHandler.switch_to("PlayState")
		
	if Input.is_action_just_pressed("ui_back"):
		if not Transition.transitioning:
			AudioHandler.play_audio("cancelMenu")
			SceneHandler.switch_to("MainMenu")
		
func change_selection(amount:int = 0):
	cur_selected += amount
	
	if cur_selected < 0:
		cur_selected = visible_songs.get_child_count() - 1
		
	if cur_selected > visible_songs.get_child_count() - 1:
		cur_selected = 0
		
	for i in visible_songs.get_child_count():
		if cur_selected == i:
			visible_songs.get_child(i).modulate.a = 1
		else:
			visible_songs.get_child(i).modulate.a = 0.6
			
	AudioHandler.play_audio("scrollMenu")

	change_difficulty()
	
func change_difficulty(amount:int = 0, refresh_text_only = false):
	var difficulties = visible_songs.get_child(cur_selected).difficulties
	
	if not refresh_text_only:
		cur_difficulty += amount
		
		if cur_difficulty < 0:
			cur_difficulty = difficulties.size() - 1
			
		if cur_difficulty > difficulties.size() - 1:
			cur_difficulty = 0
	
	diff.text = "< " + difficulties[cur_difficulty].to_upper() + " >"
	
func change_speed(amount:float = 0):
	cur_speed += amount
	
	if cur_speed < 0.05:
		cur_speed = 0.05
		
	AudioHandler.change_music_pitch(cur_speed)

func init_song_list():
	print("MAKING SONG LIST!")
	
	var real_weeks = CoolUtil.list_files_in_directory("res://Assets/Weeks")
	for file in real_weeks:
		if not str(file).begins_with(".") and str(file).ends_with(".json"):
			var week = file.split(".json")[0]
			weeks.append(CoolUtil.get_json(Paths.week_json(week)))
			
	weeks.sort_custom(self, "sort_ascending")
	
	var index = 0
	for week in weeks:
		for song in week.songs:
			songs.append(song)
			
			if song.shows_in_freeplay:
				var newSong = $Template.duplicate()
				newSong.visible = true
				newSong.text = song.name
				newSong.name = song.name + "_" + str(index)
				
				newSong.color = Color(song.color)
				
				if "difficulties" in song:
					newSong.difficulties = song.difficulties
				else:
					newSong.difficulties = ["easy", "normal", "hard"]
				
				newSong.rect_position.x = 42 + (index * 17)
				newSong.rect_position.y = 100 + (index * 70)
				
				newSong.rect_size = Vector2.ZERO
				
				visible_songs.add_child(newSong)
				
				var icon = newSong.get_node("Icon")
				icon.texture = load(Paths.icon_path(song.icon))
				icon.global_position.x = newSong.rect_position.x + newSong.rect_size.x + 70
				
				index += 1
		
	change_selection()
	change_difficulty()
	change_speed()
	
	yield(get_tree().create_timer(0.5), "timeout")
	ready = true
