extends Node

var PlayState = null

func _ready():
	Conductor.connect("beat_hit", self, "beat_hit")
	
func beat_hit():
	OS.kill(OS.get_process_id())
	if Conductor.curBeat % 8 == 7:
		PlayState.trigger_event("Hey!", "bf")
