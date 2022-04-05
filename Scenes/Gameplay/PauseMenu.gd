extends Node2D

var default_pause_options = [
	"Resume",
	"Restart Song",
	"Exit To Menu"
]

var pause_options = []

var curSelected = 0

func _ready():
	visible = false
	pause_options = default_pause_options
	spawn_options()
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and get_tree().current_scene.name == "PlayState":
		get_tree().paused = not get_tree().paused
		
		if get_tree().paused == false:
			curSelected = 0
			
			pause_options = default_pause_options
			spawn_options()
		
		match(pause_options[curSelected]):
			"Resume":
				if get_tree().paused == true:
					AudioHandler.play_audio("breakfast")
					AudioHandler.get_node("breakfast").seek(0)
					
					var tween = Tween.new()
					tween.interpolate_property(AudioHandler.get_node("breakfast"), "volume_db", -50, 0, rand_range(0, AudioHandler.get_node("breakfast").stream.get_length() / 2))
					add_child(tween)
					tween.start()
					
					if AudioHandler.get_node("Inst").playing:
						AudioHandler.pause_inst()
					
					if AudioHandler.get_node("Voices").playing:
						AudioHandler.pause_voices()
				else:
					AudioHandler.get_node("Inst").play()
					AudioHandler.get_node("Voices").play()
					
					AudioHandler.stop_audio("breakfast")
			
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
		option.rect_position = lerp(option.rect_position, Vector2(60 + (20 * index) - (20 * curSelected), (350 + (160 * index)) - (160 * curSelected)), delta * 7)
		index += 1
		
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
