extends Node2D

var curSelected = 0

var curDifficulty = 1

# hardcoding weeks for now until i find a way to get linux
# to not screw up song ordering 
var weeks = []

var week_json = null

var tracks = []

var difficulties = []

var can_select = true

# characters
onready var dad = $Characters/dad
onready var bf = $Characters/bf
onready var gf = $Characters/gf

func _ready():
	Gameplay.blueballed = 0
	
	if not AudioHandler.get_node("Inst").playing and not AudioHandler.get_node("Voices").playing and not AudioHandler.get_node("freakyMenu").playing:
		AudioHandler.play_audio("freakyMenu")
		
	Conductor.songPosition = 0
	Conductor.curBeat = 0
	Conductor.curStep = 0
	Conductor.change_bpm(102)
	Conductor.recalculate_values()
	
	Conductor.connect("beat_hit", self, "beat_hit")
	#Conductor.connect("step_hit", self, "step_hit")
	
	for file in Util.list_files_in_directory("res://Assets/Weeks"):
		if ".json" in file:
			var json = JsonUtil.get_json("res://Assets/Weeks/" + file.split(".json")[0])

			if json.shows_in_story_mode:
				weeks.append(file.split(".json")[0])
			
	var txt = Util.get_txt("res://Assets/Weeks/WeekList")
	
	var order = 0
	for fuck in txt:
		if weeks.has(fuck):
			weeks.erase(fuck)
			weeks.append(fuck)
			
		order += 1
	
	create_weeks()
	change_selection(0)
	change_difficulty(0)
	
func change_selection(amount):
	AudioHandler.play_audio("scrollMenu")
	
	curSelected += amount
	if curSelected < 0:
		curSelected = $Weeks.get_child_count() - 1
	if curSelected > $Weeks.get_child_count() - 1:
		curSelected = 0
		
	week_json = JsonUtil.get_json("res://Assets/Weeks/" + weeks[curSelected])
	
	$BG.modulate = Color(week_json.background_color)
	
	if week_json.characters[0] == "":
		week_json.characters[0] = "blank"
		
	if week_json.characters[1] == "":
		week_json.characters[1] = "blank"
		
	if week_json.characters[2] == "":
		week_json.characters[2] = "blank"
		
	var dad_load = load("res://Scenes/StoryMode/Characters/" + week_json.characters[0] + ".tscn")
	var bf_load = load("res://Scenes/StoryMode/Characters/" + week_json.characters[1] + ".tscn")
	var gf_load = load("res://Scenes/StoryMode/Characters/" + week_json.characters[2] + ".tscn")
	
	if dad_load != null and dad.name != week_json.characters[0]:
		dad.queue_free()
	else:
		dad_load = null
	if bf_load != null and bf.name != week_json.characters[1]:
		bf.queue_free()
	else:
		bf_load = null
	if gf_load != null and gf.name != week_json.characters[2]:
		gf.queue_free()
	else:
		gf_load = null
	
	if dad_load != null:
		dad = dad_load.instance()
	if bf_load != null:
		bf = bf_load.instance()
	if gf_load != null:
		gf = gf_load.instance()
	
	if dad_load != null:
		$Characters.add_child(dad)
	if bf_load != null:
		$Characters.add_child(bf)
	if gf_load != null:
		$Characters.add_child(gf)
		
	var index = 0
	var dumbasses = [dad, bf, gf]
	
	for character in dumbasses:
		character.global_position.x = 265 + (365 * index)
		character.global_position.y = 435
		index += 1
	
	difficulties = week_json.difficulties
	
	tracks = []
	for song in week_json.songs:
		tracks.append(song.name)
		
	$TrackList.text = ""
	
	for track in tracks:
		$TrackList.text += track + "\n"
		
var lerpScore = 0

func beat_hit():
	if dad.is_dancing():
		dad.dance()

	if bf.is_dancing():
		bf.dance()

	if gf.is_dancing():
		gf.dance()
	
func select_week():
	can_select = false
	Gameplay.blueballed = 0
	AudioHandler.play_audio("confirmMenu")
	
	$Weeks.get_children()[curSelected].start_flashing()
	$Characters/bf.play_anim("confirm")
	
	var timer = Timer.new()
	timer.set_wait_time(1)
	add_child(timer)
	timer.start()
	timer.set_one_shot(true)
	
	print("DIFFICULTY SELECTED: " + difficulties[curDifficulty])
	
	yield(timer, "timeout")
	AudioHandler.stop_audio("freakyMenu")
	AudioHandler.stop_audio("Inst")
	AudioHandler.stop_audio("Voices")
	
	Gameplay.song_multiplier = 1
	Gameplay.story_score = 0
	Gameplay.story_mode = true
	Gameplay.story_playlist = tracks
	Gameplay.difficulty = difficulties[curDifficulty]
	Gameplay.SONG = JsonUtil.get_json("res://Assets/Songs/" + Gameplay.story_playlist[0] + "/" + difficulties[curDifficulty].to_lower())
	SceneManager.switch_scene("PlayState")
		
func _process(delta):
	if can_select and Input.is_action_just_pressed("ui_accept"):
		select_week()
		
	if AudioHandler.get_node("freakyMenu").playing:
		Conductor.songPosition = (AudioHandler.get_node("freakyMenu").get_playback_position() * 1000)
	else:
		Conductor.songPosition += (delta * 1000)
		
	if curDifficulty > len(difficulties) - 1:
		curDifficulty = 0
		change_difficulty(0)
		
	var index = 0
	for week in $Weeks.get_children():
		week.modulate.a = 0.6
		week.global_position = lerp(week.global_position, Vector2(640, 514 + (130 * (index - curSelected))), delta * 10)
		
		if curSelected == index:
			week.modulate.a = 1
			
		index += 1
		
	if can_select:
		if Input.is_action_just_pressed("ui_back"):
			can_select = false
			AudioHandler.play_audio("cancelMenu")
			SceneManager.switch_scene("MainMenu")
			
		if Input.is_action_just_pressed("ui_up"):
			change_selection(-1)
			
		if Input.is_action_just_pressed("ui_down"):
			change_selection(1)
			
		if Input.is_action_just_pressed("ui_left"):
			change_difficulty(-1)
			
		if Input.is_action_just_pressed("ui_right"):
			change_difficulty(1)
		
	lerpScore = lerp(lerpScore, WeekHighscore.get_score(weeks[curSelected].to_lower().replace(" ", "-")), delta * 20)
	$PersonalBest.text = "PERSONAL BEST: " + str(abs(round(lerpScore)))
	
	$WeekDescription.text = week_json.description
		
func change_difficulty(amount):
	curDifficulty += amount
	if curDifficulty < 0:
		curDifficulty = len(difficulties) - 1
	if curDifficulty > len(difficulties) - 1:
		curDifficulty = 0
		
	$Difficulty.difficulty = difficulties[curDifficulty]
	$Difficulty.refresh()
	
func create_weeks():
	var index = 0
	for week in weeks:
		var json = JsonUtil.get_json("res://Assets/Weeks/" + weeks[index])
		var newWeek = $WeekTemplate.duplicate()
		newWeek.visible = true
		newWeek.week_name = week
		newWeek.texture = load("res://Assets/Images/StoryMode/" + json.texture + ".png")
		newWeek.global_position = Vector2(640, (514 * 0.5))
		$Weeks.add_child(newWeek)
		
		index += 1
