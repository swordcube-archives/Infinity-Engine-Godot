extends Modchart

onready var PlayState = $"../"

func _ready():
	Conductor.connect("beat_hit", self, "beat_hit")
	
	if GameplaySettings.story_mode:
		start_dialogue($DialogueBox)
	
func beat_hit():
	if Conductor.cur_beat % 16 == 15 and Conductor.cur_beat > 16 and Conductor.cur_beat < 48:
		if PlayState.bf:
			PlayState.trigger_event("Hey!", "bf")
		
		if PlayState.dad:
			PlayState.dad.play_anim('cheer', true)
			PlayState.dad.special_anim = true
