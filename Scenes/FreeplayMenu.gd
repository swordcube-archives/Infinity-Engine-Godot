extends Node2D

var json
var bg_tween = Tween.new()

var curSelected = 0

var playing = false

func _ready():
	# read the json
	json = JsonUtil.get_json("res://Assets/Data/FreeplaySongList")
	
	$Misc/Transition._fade_out()
	
	var index = 0
	for song in json.songs:
		print(song)
		var newSong = $Template.duplicate()
		newSong.visible = true
		newSong.text = song.name.to_upper()
		newSong.name = song.name.to_lower() + "_" + str(index)
		newSong.rect_position.x += (20 * index)
		newSong.rect_position.y = 350 + (160 * index)
		newSong.rect_size = Vector2(0, 0)
		$Songs.add_child(newSong)
		
		newSong.get_node("Icon").texture = load("res://Assets/Images/Icons/" + song.icon + ".png")
		newSong.get_node("Icon").global_position.x = newSong.rect_position.x + newSong.rect_size.x + 90
		index += 1
		
	change_selection(0)
	
	var bg_color = Color(json.songs[curSelected].color)
	$BG/BG.modulate.r = bg_color.r
	$BG/BG.modulate.g = bg_color.g
	$BG/BG.modulate.b = bg_color.b
		
func change_selection(amount):
	AudioHandler.play_audio("scrollMenu")
	
	curSelected += amount
	if curSelected < 0:
		curSelected = $Songs.get_child_count() - 1
	if curSelected > $Songs.get_child_count() - 1:
		curSelected = 0
		
	var song_index = 0
	for song in $Songs.get_children():
		song.modulate.a = 0.6
		
	$Songs.get_children()[curSelected].modulate.a = 1
		
	$Cam.position.x = $Songs.get_children()[curSelected].rect_position.x - 60
	$Cam.position.y = $Songs.get_children()[curSelected].rect_position.y - 340
	
	bg_tween.interpolate_property($BG/BG, "modulate", $BG/BG.modulate, Color(json.songs[curSelected].color), 1)
	add_child(bg_tween)
	bg_tween.start()

func _process(delta):
	if Input.is_action_just_pressed("ui_back"):
		AudioHandler.play_audio("cancelMenu")
		$Misc/Transition.transition_to_scene("MainMenu")
		
	if Input.is_action_just_pressed("ui_up"):
		change_selection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		change_selection(1)
		
	if Input.is_action_just_pressed("ui_accept"):
		if not playing:
			playing = true
			AudioHandler.stop_audio("freakyMenu")
			AudioHandler.play_inst(json.songs[curSelected].name)
			AudioHandler.play_voices(json.songs[curSelected].name)
		else:
			AudioHandler.stop_audio("freakyMenu")
			AudioHandler.stop_inst()
			AudioHandler.stop_voices()
			
			var song = "res://Assets/Songs/" + json.songs[curSelected].name + "/hard"
			print("SONG TO LOAD: " + song)
			Gameplay.SONG = JsonUtil.get_json(song)
			#print(Gameplay.SONG)
			$Misc/Transition.transition_to_scene("PlayState")
