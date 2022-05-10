extends Node

onready var PlayState = $"../"

func _ready():
	Conductor.connect("beat_hit", self, "beat_hit")
	
func beat_hit():
	if Conductor.cur_beat % 8 == 7:
		PlayState.trigger_event("Hey!", "bf")
