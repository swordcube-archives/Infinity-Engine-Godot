extends Node2D

onready var inst = $Gameplay/Inst
onready var voices = $Gameplay/Voices

# for music
func play_music(music_to_play):		
	var node = get_node("Music/" + music_to_play)
	if node and not node.playing:
		var music = get_node("Music").get_children()
		for file in music:
			file.stop()
		
		node.play()
		
func stop_music():
	var music = get_node("Music").get_children()
	for file in music:
		file.stop()
		
func play_inst(song):
	var music = get_node("Music").get_children()
	for file in music:
		file.stop()
		
	inst.stop()
	inst.stream = load("res://Assets/Songs/" + song + "/Inst.ogg")
	inst.play(0)
	
func play_voices(song):
	voices.stop()
	voices.stream = load("res://Assets/Songs/" + song + "/Voices.ogg")
	voices.play()
		
# for sound effects
func play_audio(audio, pos = 0):
	get_node(audio).play(pos)
	
func stop_audio(audio):
	get_node(audio).stop()
	
func pause_audio(audio):
	stop_audio(audio)
