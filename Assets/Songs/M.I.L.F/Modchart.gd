extends Node2D

# preparing this in advance so i don't have to
# add it later

onready var PlayState = $"../"

func _ready():
	Conductor.connect("beat_hit", self, "beat_hit")
	
func beat_hit():
	if Conductor.curBeat >= 168 and Conductor.curBeat < 200:
		PlayState.trigger_event("Add Camera Zoom", 0.015, 0.03)
