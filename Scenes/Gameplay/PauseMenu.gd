extends Node2D

var default_pause_options = [
	"Resume",
	"Restart Song",
	"Exit To Menu"
]

var pause_options = []

var curSelected = 0

var tween = Tween.new()

func _ready():
	visible = false
	pause_options = default_pause_options
	spawn_options()
	
func _process(delta):
	$SongName.text = Gameplay.SONG.song.song
	$Difficulty.text = Gameplay.difficulty.to_upper()
	
	if get_tree().paused == true:
		AudioHandler.pause_inst()
		AudioHandler.pause_voices()
	
	if Input.is_action_just_pressed("ui_confirm") and get_tree().current_scene.name == "PlayState":
		if get_tree().current_scene.can_pause:
			if get_tree().paused == true:
				match(pause_options[curSelected]):
					"Resume":
						get_tree().paused = not get_tree().paused
						
						if not get_tree().current_scene.countdown_active:
							get_tree().current_scene.resync_vocals()
						
						var inst_pos = AudioHandler.get_node("Inst").get_playback_position()
						var voices_pos = AudioHandler.get_node("Voices").get_playback_position()
						
						if AudioHandler.get_node("Inst").stream != null:
							AudioHandler.unpause_inst()
							AudioHandler.get_node("Inst").seek(inst_pos)
							
						if AudioHandler.get_node("Voices").stream != null:
							AudioHandler.unpause_voices()
							AudioHandler.get_node("Voices").seek(voices_pos)
						
						AudioHandler.stop_audio("breakfast")
					"Restart Song":
						AudioHandler.stop_audio("breakfast")
						
						get_tree().reload_current_scene()
						get_tree().paused = not get_tree().paused
					"Exit To Menu":
						AudioHandler.stop_audio("breakfast")
						AudioHandler.play_audio("freakyMenu")
						
						if Gameplay.story_mode:
							SceneManager.switch_scene("StoryMenu")
						else:
							SceneManager.switch_scene("FreeplayMenu")
							
						get_tree().paused = not get_tree().paused
			else:
				get_tree().paused = not get_tree().paused
				
				get_tree().current_scene.get_node("Misc/Transition").visible = false
				
				$SongName.rect_position.y = 0
				$SongName.modulate.a = 0
				
				$Difficulty.rect_position.y = 22
				$Difficulty.modulate.a = 0
				
				AudioHandler.get_node("breakfast").volume_db = -50
				AudioHandler.play_audio("breakfast")
				AudioHandler.get_node("breakfast").seek(0)
				
				remove_child(tween)
				tween.stop_all()
				tween = Tween.new()
				tween.interpolate_property(AudioHandler.get_node("breakfast"), "volume_db", -50, 0, AudioHandler.get_node("breakfast").stream.get_length() / 2)
				# 22 and 54
				tween.interpolate_property($SongName, "rect_position", $SongName.rect_position, Vector2($SongName.rect_position.x, 22), 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
				tween.interpolate_property($SongName, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
				
				piss()
				
				$BG.modulate.a = 0
				tween.interpolate_property($BG, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.2)
				add_child(tween)
				tween.start()
					
				pause_options = default_pause_options
				spawn_options()
			
	if get_tree().paused == true:
		visible = true
		
		if Input.is_action_just_pressed("ui_up"):
			change_selection(-1)
			
		if Input.is_action_just_pressed("ui_down"):
			change_selection(1)
	else:
		visible = false
		
	var index = 0
	for option in $Options.get_children():
		option.rect_position = lerp(option.rect_position, Vector2(60 + (20 * index) - (20 * curSelected), (350 + (160 * index)) - (160 * curSelected)), delta * 10)
		index += 1
		
func piss():
	var timer = Timer.new()
	timer.set_wait_time(0.3)
	add_child(timer)
	timer.start()
	timer.set_one_shot(true)
	
	yield(timer, "timeout")
	tween.interpolate_property($Difficulty, "rect_position", $Difficulty.rect_position, Vector2($Difficulty.rect_position.x, 54), 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property($Difficulty, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		
func change_selection(amount):
	AudioHandler.play_audio("scrollMenu")
	
	curSelected += amount
	if curSelected < 0:
		curSelected = len(pause_options) - 1
	if curSelected > len(pause_options) - 1:
		curSelected = 0
		
	for option in $Options.get_children():
		option.modulate.a = 0.6
		
	$Options.get_children()[curSelected].modulate.a = 1
		
func spawn_options():
	for option in $Options.get_children():
		$Options.remove_child(option)
		
	var index = 0
	for option in pause_options:
		var newSong = $OptionTemplate.duplicate()
		newSong.visible = true
		newSong.text = option
		newSong.name = option
		newSong.rect_position.x += 20
		newSong.rect_position.y = (160 + (50 * index))
		newSong.rect_size = Vector2(0, 0)
		$Options.add_child(newSong)
		
		index += 1
		
	curSelected = 0
	change_selection(0)
