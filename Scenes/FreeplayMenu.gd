extends Node2D

onready var bg = $BG
onready var visible_songs = $Songs

var weeks:Array = []
var songs:Array = []

var ready:bool = false

var cur_selected:int = 0

func sort_ascending(a, b):
	if a.week_num < b.week_num:
		return true
		
	return false

func _ready():
	AudioHandler.play_music("freakyMenu")
	
	init_song_list()
	
func _physics_process(delta):
	if ready:
		bg.modulate = lerp(bg.modulate, Color(songs[cur_selected].color), delta * 2)
		var index = 0
		for song in visible_songs.get_children():
			var x = song.rect_position.x
			var y = song.rect_position.y
			song.rect_position.x = lerp(x, 95 + ((index - cur_selected) * 17), delta * 10)
			song.rect_position.y = lerp(y, 335 + ((index - cur_selected) * 155), delta * 10)
			
			index += 1
			
func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		change_selection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		change_selection(1)
		
	if Input.is_action_just_pressed("ui_space"):
		AudioHandler.play_inst(songs[cur_selected].name)
		AudioHandler.play_voices(songs[cur_selected].name)
		
		AudioHandler.inst.seek(0)
		AudioHandler.voices.seek(0)
		
	if Input.is_action_just_pressed("ui_back"):
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
				
				newSong.color = Color(song.color)
				newSong.rect_position.x = 42 + (index * 20)
				newSong.rect_position.y = 100 + (index * 70)
				
				newSong.rect_size = Vector2.ZERO
				
				visible_songs.add_child(newSong)
				
				var icon = newSong.get_node("Icon")
				icon.texture = load(Paths.icon_path(song.icon))
				icon.global_position.x = newSong.rect_position.x + newSong.rect_size.x + 70
				
				index += 1
		
	yield(get_tree().create_timer(0.1), "timeout")
	change_selection()
	ready = true
