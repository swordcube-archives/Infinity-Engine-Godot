extends Node

var PlayState = null

func _ready():
	Conductor.connect("beat_hit", self, "beat_hit")
	
func beat_hit():
	if Conductor.curBeat % 16 == 15 and Conductor.curBeat > 16 and Conductor.curBeat < 48:
		PlayState.trigger_event("Hey!", "bf")
		
		PlayState.dad.play_anim('cheer', true)
		PlayState.dad.special_anim = true
