extends Node2D

var curSelected = 0

var curDifficulty = 1

# hardcoding weeks for now until i find a way to get linux
# to not screw up song ordering 
var weeks = []

var week_json = null

var tracks = []

var difficulties = []

func _ready():
	$Misc/Transition._fade_out()
	
	for file in Util.list_files_in_directory("res://Assets/Weeks"):
		if ".json" in file:
			weeks.append(file.split(".json")[0])
			
	var txt = Util.get_txt("res://Assets/Weeks/WeekList")
	
	var order = 0
	for fuck in txt:
		if weeks.has(fuck):
			weeks.erase(fuck)
			weeks.insert(order, fuck)
			
		order += 1
		
	print("WEEKS: " + str(weeks))
	
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
	
	difficulties = week_json.difficulties
	
	tracks = []
	for song in week_json.songs:
		tracks.append(song.name)
		
	$TrackList.text = ""
	
	for track in tracks:
		$TrackList.text += track + "\n"
		
var lerpScore = 0
		
func _process(delta):
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
		
	if Input.is_action_just_pressed("ui_back"):
		$Misc/Transition.transition_to_scene("MainMenu")
		
	if Input.is_action_just_pressed("ui_up"):
		change_selection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		change_selection(1)
		
	if Input.is_action_just_pressed("ui_left"):
		change_difficulty(-1)
		
	if Input.is_action_just_pressed("ui_right"):
		change_difficulty(1)
		
	lerpScore = lerp(lerpScore, WeekHighscore.get_score(weeks[curSelected].to_lower().replace(" ", "-")), delta * 20)
	$PersonalBest.text = "PERSONAL BEST: " + str(round(lerpScore))
		
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
		var newWeek = $WeekTemplate.duplicate()
		newWeek.visible = true
		newWeek.week_name = week
		newWeek.texture = load("res://Assets/Images/StoryMode/" + weeks[index] + ".png")
		newWeek.global_position = Vector2(640, (514 * 0.5))
		$Weeks.add_child(newWeek)
		
		index += 1
