extends Modchart

var heyEvent = load("res://Scenes/Events/Hey!.tscn").instance()

onready var PlayState = $"../"

func _ready():
	Conductor.connect("beat_hit", self, "beat_hit")
	
	if GameplaySettings.story_mode:
		start_dialogue($DialogueBox)
	
func beat_hit():
	if Conductor.cur_beat % 16 == 15 and Conductor.cur_beat > 16 and Conductor.cur_beat < 48:
		if PlayState.bf:
			heyEvent.params["Character"] = "bf"
			heyEvent.PlayState = PlayState
			heyEvent.on_event()
		
		if PlayState.dad:
			heyEvent.params["Character"] = "dad"
			heyEvent.PlayState = PlayState
			heyEvent.on_event()
