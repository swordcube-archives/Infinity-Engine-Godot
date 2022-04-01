extends Node2D

func play_audio(name):
	get_node(name).play()
	
func pause_audio(name):
	get_node(name).pause()
	
func stop_audio(name):
	get_node(name).stop()
