extends Node2D

var default_pause_options:Array = [
	"Resume",
	"Restart Song",
	"Toggle Practice Mode",
	"Change Difficulty",
	"Exit to Menu",
]

var pause_options:Array = default_pause_options

onready var volume_tween = $VolumeTween
onready var pause_music = $PauseMusic
onready var bg = $BG
onready var PlayState = $"../../"
onready var options = $Options
onready var template = $Template

onready var text = [
	$Text/Song,
	$Text/Diff,
	$Text/Deaths,
	$Text/Practice,
]

var changing_difficulty:bool = false

var ready:bool = false
var cur_selected:int = 0

func _physics_process(delta):
	bg.modulate.a = lerp(bg.modulate.a, 1, delta * 7)
	if ready:
		var index = 0
		for song in options.get_children():
			var x = song.rect_position.x
			var y = song.rect_position.y
			song.rect_position.x = lerp(x, 95 + ((index - cur_selected) * 17), delta * 10)
			song.rect_position.y = lerp(y, 335 + ((index - cur_selected) * 155), delta * 10)
			
			index += 1

func _process(delta):
	text[3].visible = GameplaySettings.practice_mode
	if not get_tree().paused:
		if not Transition.transitioning and Input.is_action_just_pressed("ui_confirm"):
			bg.modulate.a = 0
			
			get_tree().paused = true
			visible = get_tree().paused
			
			MobileControls.switch_to("dpad_pausemenu")
			
			pause_options = default_pause_options
			spawn_options()
			
			pause_music.volume_db = -50
			pause_music.play(0)
			volume_tween.interpolate_property(pause_music, "volume_db", -50, 0, pause_music.stream.get_length() / 2)
			volume_tween.start()
			
			text[0].text = GameplaySettings.SONG.song.song
			text[1].text = GameplaySettings.difficulty.to_upper()
			text[2].text = "Blueballed: " + str(GameplaySettings.deaths)
			
			var index:int = 0
			for shit in text:
				shit.modulate.a = 0
				shit.rect_position.y = 6 + (30 * index)
				volume_tween.interpolate_property(shit, "modulate:a", shit.modulate.a, 1, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.3 * (index + 1))
				volume_tween.interpolate_property(shit, "rect_position:y", shit.rect_position.y, shit.rect_position.y + 10, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.3 * (index + 1))
				
				index += 1
			
			cur_selected = 0
			change_selection()
	else:
		AudioHandler.inst.stop()
		AudioHandler.voices.stop()
		
		if Input.is_action_just_pressed("ui_up"):
			change_selection(-1)
			
		if Input.is_action_just_pressed("ui_down"):
			change_selection(1)
			
		if Input.is_action_just_pressed("ui_confirm"):
			if not changing_difficulty:
				match pause_options[cur_selected]:
					"Resume":
						get_tree().paused = false
						visible = get_tree().paused
						
						AudioHandler.inst.play(Conductor.song_position / 1000.0)
						AudioHandler.voices.play(Conductor.song_position / 1000.0)
						
						volume_tween.stop_all()
						pause_music.stop()
						
						MobileControls.switch_to("hitbox")
					"Restart Song":
						get_tree().paused = false
						visible = get_tree().paused
						
						PlayState.started_countdown = false
						PlayState.countdown_timer.stop()
						SceneHandler.switch_to("PlayState")
					"Toggle Practice Mode":
						if not GameplaySettings.practice_mode:
							GameplaySettings.used_practice = true
							
						GameplaySettings.practice_mode = not GameplaySettings.practice_mode
					"Change Difficulty":
						changing_difficulty = true
						
						pause_options = ["back"]
						
						var files = CoolUtil.list_files_in_directory(Paths.song(GameplaySettings.SONG.song.song))
						for file in files:
							if not file.begins_with(".") and file.ends_with(".json"):
								var split = file.split(".json")[0]
								if not "dialogue" in split:
									pause_options.append(split)
								
						if pause_options.has("hard"):
							pause_options.erase("hard")
							pause_options.insert(0, "hard")
							
						if pause_options.has("normal"):
							pause_options.erase("normal")
							pause_options.insert(0, "normal")
							
						if pause_options.has("easy"):
							pause_options.erase("easy")
							pause_options.insert(0, "easy")
							
						spawn_options()
						
						cur_selected = 0
						change_selection()
								
					"Exit to Menu":
						get_tree().paused = false
						visible = get_tree().paused
						
						PlayState.started_countdown = false
						PlayState.countdown_timer.stop()
						
						AudioHandler.play_music("freakyMenu")
						if GameplaySettings.story_mode:
							SceneHandler.switch_to("StoryMenu")
						else:
							SceneHandler.switch_to("FreeplayMenu")
			else:
				match pause_options[cur_selected]:
					"back":
						changing_difficulty = false
						pause_options = default_pause_options
						
						spawn_options()
						
						cur_selected = 0
						yield(get_tree().create_timer(0.1), "timeout")
						change_selection()
					_:
						get_tree().paused = false
						visible = get_tree().paused
						
						var songName:String = GameplaySettings.SONG.song.song
						GameplaySettings.difficulty = pause_options[cur_selected]
						GameplaySettings.SONG = CoolUtil.get_json(Paths.song_json(songName, GameplaySettings.difficulty))
						
						PlayState.started_countdown = false
						PlayState.countdown_timer.stop()
						SceneHandler.switch_to("PlayState")
			
func change_selection(amount:int = 0):
	cur_selected += amount
	if cur_selected < 0:
		cur_selected = pause_options.size() - 1
	if cur_selected > pause_options.size() - 1:
		cur_selected = 0
		
	var index:int = 0
	for option in options.get_children():
		if cur_selected == index:
			option.modulate.a = 1
		else:
			option.modulate.a = 0.6
			
		index += 1
		
	AudioHandler.play_audio("scrollMenu")
				
func spawn_options():
	ready = false
	for option in options.get_children():
		options.remove_child(option)
		option.queue_free()
		
	var index:int = 0
	for option in pause_options:
		var new_option = template.duplicate()
		new_option.visible = true
		new_option.rect_position.x = 42 + (index * 17)
		new_option.rect_position.y = 100 + (index * 70)
		new_option.text = option
		options.add_child(new_option)
		
		index += 1
		
	ready = true
