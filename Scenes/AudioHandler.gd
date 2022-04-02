extends Node2D

func play_audio(name):
	get_node(name).play()
	
func pause_audio(name):
	get_node(name).pause()
	
func stop_audio(name):
	get_node(name).stop()

# song bullshit

# loading

func play_inst(name):
	$Inst.stream = load("res://Assets/Songs/" + name + "/Inst.ogg")
	$Inst.play()
	
func play_voices(name):
	$Voices.stream = load("res://Assets/Songs/" + name + "/Voices.ogg")
	$Voices.play()
	
# misc
	
func pause_inst():
	$Inst.pause()
	
func unpause_inst():
	$Inst.play()
	
func stop_inst():
	$Inst.stop()
	
# misc but for voices
	
func pause_voices():
	$Voices.pause()
	
func unpause_voices():
	$Voices.play()
	
func stop_voices():
	$Voices.stop()
