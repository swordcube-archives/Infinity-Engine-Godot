extends Node2D

onready var inst = $Gameplay/Inst
onready var voices = $Gameplay/Voices
onready var freakyMenu = $Music/freakyMenu

# for music
func change_music_pitch(pitch):
	var music = get_node("Music").get_children()
	for file in music:
		file.pitch_scale = pitch
		
	inst.pitch_scale = pitch
	voices.pitch_scale = pitch
		
func play_music(music_to_play):		
	var node = get_node("Music/" + music_to_play)
	if node and not inst.playing and not voices.playing and not node.playing:
		var music = get_node("Music").get_children()
		for file in music:
			file.stop()
		
		node.play()
		
func stop_music():
	var music = get_node("Music").get_children()
	for file in music:
		file.stop()
		
	inst.stop()
	voices.stop()
		
func play_inst(song):
	var music = get_node("Music").get_children()
	for file in music:
		file.stop()
		
	inst.stop()
	inst.stream = load(Paths.inst(song))
	inst.play(0)
	inst.volume_db = 0
	
func play_voices(song):
	voices.stop()
	voices.stream = load(Paths.voices(song))
	voices.play(0)
	voices.volume_db = 0
		
# for sound effects
# 0 = full volume btw, volume works in decibels in godot
func play_audio(audio, pos:float = 0, volume:float = 0):
	var node = get_node(audio)
	node.play(pos)
	node.volume_db = volume
	
func stop_audio(audio):
	get_node(audio).stop()
	
func pause_audio(audio):
	stop_audio(audio)
