extends Node

onready var PlayState = $"../"

var heyEvent = load("res://Scenes/Events/Hey!.tscn").instance()

func _ready():
	heyEvent.params["Character"] = "bf"
	heyEvent.PlayState = PlayState
	Conductor.connect("beat_hit", self, "beat_hit")
	
func beat_hit():
	if Conductor.cur_beat % 8 == 7:
		heyEvent.on_event()
