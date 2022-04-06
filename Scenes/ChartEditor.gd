extends Node2D

var stopped_init_audio = false

func _ready():
	$Misc/Transition._fade_out()

func _process(delta):
	if not stopped_init_audio:
		if AudioHandler.get_node("Inst").playing:
			stopped_init_audio = true
			AudioHandler.stop_inst()
			
		if AudioHandler.get_node("Voices").playing:
			AudioHandler.stop_voices()
