extends Node2D

var weeks = []
var songs = []

var json
var bg_tween = Tween.new()

var curSelected = 0
var curDifficulty = 1

var playing = ""

var can_enter = true

func _ready():	
	add_child(bg_tween)
	Gameplay.blueballed = 0
	
	if not AudioHandler.get_node("Inst").playing and not AudioHandler.get_node("Voices").playing and not AudioHandler.get_node("freakyMenu").playing:
		AudioHandler.play_audio("freakyMenu")
	
	for file in Util.list_files_in_directory("res://Assets/Weeks"):
		if not file.begins_with(".") and file.ends_with(".json"):
			weeks.append(file.split(".json")[0])
			
	var txt = Util.get_txt("res://Assets/Weeks/WeekList")
	
	var order = 0
	for fuck in txt:
		if weeks.has(fuck):
			weeks.erase(fuck)
			weeks.append(fuck)
			
		order += 1
		
	for mod in ModManager.active_mods:
		var m_txt = Util.get_txt("res://Assets/Weeks/" + mod + "-WeekList")
	
		var m_order = 0
		for fuck in m_txt:
			if weeks.has(fuck):
				weeks.erase(fuck)
				weeks.append(fuck)
				
			m_order += 1
		
	#print(weeks)
	
	# read the json
	var week_index = 0
	for week in weeks:
		json = JsonUtil.get_json("res://Assets/Weeks/" + week)
		
		for song in json.songs:
			if json.shows_in_freeplay:			
				songs.append(song)
			
		week_index += 1
	
	var index = 0
	for song in songs:
		#print(song)
		var newSong = $Template.duplicate()
		newSong.visible = true
		newSong.text = song.name.to_upper()
		newSong.name = song.name.to_lower() + "_" + str(index)
		newSong.rect_position.x += (20 * index)
		newSong.rect_position.y = 60 + (50 * index)
		newSong.rect_size = Vector2(0, 0)
		$Songs.add_child(newSong)
		
		newSong.get_node("Icon").texture = load("res://Assets/Images/Icons/" + song.icon + ".png")
		newSong.get_node("Icon").global_position.x = newSong.rect_position.x + newSong.rect_size.x + 90
		index += 1
		
	#print(songs[curSelected])
		
	change_selection(0)
	
	$BG/BG.modulate = Color(songs[curSelected].color)
		
func change_selection(amount):
	AudioHandler.play_audio("scrollMenu")
	
	curSelected += amount
	if curSelected < 0:
		curSelected = $Songs.get_child_count() - 1
	if curSelected > $Songs.get_child_count() - 1:
		curSelected = 0
		
	for song in $Songs.get_children():
		song.modulate.a = 0.6
		
	$Songs.get_children()[curSelected].modulate.a = 1
	
	bg_tween.interpolate_property($BG/BG, "modulate", $BG/BG.modulate, Color(songs[curSelected].color), 1)
	bg_tween.start()
	
	position_highscore()
	change_difficulty(0)

func change_difficulty(amount):
	curDifficulty += amount
	if curDifficulty < 0:
		curDifficulty = len(songs[curSelected].difficulties) - 1
	if curDifficulty > len(songs[curSelected].difficulties) - 1:
		curDifficulty = 0
		
	$Difficulty.text = "< " + songs[curSelected].difficulties[curDifficulty].to_upper() + " >"
	$Difficulty.text += " - Speed: " + str(Gameplay.song_multiplier)
	position_highscore()
	
var lerpScore = 0
var lerpAcc = 0

var hold_time = 0.0

func _input(event):
	var shift = Input.is_action_pressed("ui_shift")
	var just_pressed = event.is_pressed() and not event.is_echo()
	
	if just_pressed and event is InputEventKey and event.pressed:
		if shift and event.scancode == KEY_R:
			Gameplay.song_multiplier = 1
			change_speed(0)

func _process(delta):	
	var shift = Input.is_action_pressed("ui_shift")
	
	if Input.is_action_just_pressed("ui_back"):
		AudioHandler.play_audio("cancelMenu")
		SceneManager.switch_scene("MainMenu")
		
	if Input.is_action_just_pressed("ui_up"):
		change_selection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		change_selection(1)
		
	if shift:
		if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
			hold_time += delta
			
			if hold_time > 0.5 or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
				var mult = 0.05
				if Input.is_action_pressed("ui_left"):
					mult = -0.05
				
				change_speed(mult)
		else:
			hold_time = 0
	else:
		hold_time = 0
		
		if Input.is_action_just_pressed("ui_left"):
			change_difficulty(-1)
				
		if Input.is_action_just_pressed("ui_right"):
			change_difficulty(1)
		
	if Input.is_action_just_pressed("space"):
		if not playing == songs[curSelected].name:
			playing = songs[curSelected].name
			AudioHandler.stop_audio("freakyMenu")
			AudioHandler.play_inst(songs[curSelected].name)
			AudioHandler.play_voices(songs[curSelected].name)
			
			AudioHandler.get_node("Inst").seek(0)
			AudioHandler.get_node("Voices").seek(0)
		else:
			start_song()
			
	if Input.is_action_just_pressed("ui_confirm"):
		start_song()
		
	var index = 0
	for song in $Songs.get_children():
		song.rect_position = lerp(song.rect_position, Vector2(60 + (20 * index) - (20 * curSelected), (350 + (160 * index)) - (160 * curSelected)), delta * 10)
		index += 1
		
	if curDifficulty > len(songs[curSelected].difficulties) - 1:
		curDifficulty = 0
		change_difficulty(0)
		
	lerpScore = lerp(lerpScore, SongHighscore.get_score(songs[curSelected].name.to_lower().replace(" ", "-") + "-" + songs[curSelected].difficulties[curDifficulty].to_lower()), delta * 15)
	lerpAcc = lerp(lerpAcc, SongAccuracy.get_acc(songs[curSelected].name.to_lower().replace(" ", "-") + "-" + songs[curSelected].difficulties[curDifficulty].to_lower()), delta * 15)
	$PersonalBest.text = "PERSONAL BEST: " + str(abs(round(lerpScore))) + " (" + str(abs(Util.round_decimal(lerpAcc, 2))) + "%)"
	position_highscore()
	
func change_speed(amount):
	Gameplay.song_multiplier += amount
	
	if Gameplay.song_multiplier < 0.1:
		Gameplay.song_multiplier = 0.1
		
	Gameplay.song_multiplier = Util.round_decimal(Gameplay.song_multiplier, 2)
		
	AudioHandler.get_node("Inst").pitch_scale = Gameplay.song_multiplier
	AudioHandler.get_node("Voices").pitch_scale = Gameplay.song_multiplier
	
	change_difficulty(0)
	
func position_highscore():
	$PersonalBest.rect_size.x = 0
	$Difficulty.rect_size.x = 0
	
	$ScoreBG.rect_size.x = $PersonalBest.rect_size.x + 15
	
	$PersonalBest.rect_position.x = (ScreenRes.screen_width - $PersonalBest.rect_size.x) - 5
	
	if $Difficulty.rect_size.x > $PersonalBest.rect_size.x:
		$ScoreBG.rect_size.x = $Difficulty.rect_size.x + 15
		$PersonalBest.rect_position.x = (ScreenRes.screen_width - $PersonalBest.rect_size.x) - 5
	
	$PersonalBest.rect_position.y = 5
	
	if $PersonalBest.rect_size.x > $Difficulty.rect_size.x:
		$Difficulty.rect_position.x = (($PersonalBest.rect_position.x + ($PersonalBest.rect_size.x / 2)) - ($Difficulty.rect_size.x / 2)) - 5
	else:
		$Difficulty.rect_position.x = (ScreenRes.screen_width - $Difficulty.rect_size.x) - 5
	
	$Difficulty.rect_position.y = $PersonalBest.rect_position.y + $PersonalBest.rect_size.y
	
	$ScoreBG.rect_size.y = $PersonalBest.rect_size.y + $Difficulty.rect_size.y + 5
	
	$ScoreBG.rect_position.x = (ScreenRes.screen_width - $ScoreBG.rect_size.x)
	$ScoreBG.rect_position.y = 0
			
func start_song():
	if can_enter:
		can_enter = false
		Gameplay.story_mode = false
		Gameplay.blueballed = 0
		
		AudioHandler.stop_audio("freakyMenu")
		AudioHandler.stop_inst()
		AudioHandler.stop_voices()
		
		var song = "res://Assets/Songs/" + songs[curSelected].name + "/" + songs[curSelected].difficulties[curDifficulty].to_lower()
		print("SONG TO LOAD: " + song)
		Gameplay.SONG = JsonUtil.get_json(song)
		Gameplay.difficulty = songs[curSelected].difficulties[curDifficulty].to_lower()
		#print(Gameplay.SONG)
		SceneManager.switch_scene("PlayState")
