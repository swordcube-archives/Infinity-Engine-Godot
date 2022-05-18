extends CanvasLayer

class_name Modchart

func opponent_note_hit(direction, type, is_sustain):
	pass
	
func player_note_hit(direction, type, is_sustain):
	pass
	
func opponent_note_miss(direction, type, is_sustain):
	pass
	
func player_note_miss(direction, type, is_sustain):
	pass
	
func start_dialogue(dialogue):
	var loaded_json = CoolUtil.get_json(Paths.song(GameplaySettings.SONG.song.song) + "/dialogue.json")
	dialogue.json = loaded_json
	
	if loaded_json != null:
		var PlayState = $"../"
		PlayState.can_pause = false
		PlayState.started_countdown = false
		dialogue.visible = true
		dialogue.start()
