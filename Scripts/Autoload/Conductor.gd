extends Node

var song_position:float = 0.0
var bpm:float = 100.0

var crochet:float = ((60 / bpm) * 1000)
var step_crochet:float = crochet / 4

var cur_beat:int = 0
var cur_step:int = 0

var safe_zone_offset:float = 166

var bpm_changes:Array = []

signal beat_hit
signal step_hit

func recalculate_values():
	crochet = ((60 / bpm) * 1000)
	step_crochet = crochet / 4

func change_bpm(new_bpm, changes = []):
	if len(changes) == 0:
		changes = [[0, float(new_bpm), 0]]
	
	bpm_changes = changes
	bpm = float(new_bpm)
	recalculate_values()

func map_bpm_changes(songData):
	var changes = []
	
	var cur_bpm:float = songData["bpm"]
	var total_steps:int = 0
	var total_pos:float = 0.0
	
	for section in songData["notes"]:
		if "changeBPM" in section:
			if section["changeBPM"] and section["bpm"] != cur_bpm:
				cur_bpm = section["bpm"]
				
				var change = [total_pos, section["bpm"], total_steps]
				
				changes.append(change)
		
		if not "lengthInSteps" in section:
			section["lengthInSteps"] = 16
		
		var section_length:int = section["lengthInSteps"]
		
		total_steps += section_length
		total_pos += ((60 / cur_bpm) * 1000 / 4) * section_length
	
	return changes

func _physics_process(delta):
	var old_beat = cur_beat
	var old_step = cur_step

	var last_change:Array = [0,0,0]
	
	for change in bpm_changes:
		if song_position >= change[0]:
			last_change = change
			
			bpm = change[1]
			recalculate_values()
	
	if len(last_change) < 3:
		last_change.append(0)
	
	cur_step = last_change[2] + floor((song_position - last_change[0]) / step_crochet)
	cur_beat = floor(cur_step / 4)
	
	if cur_step != old_step and cur_step > old_step:
		emit_signal("step_hit")
	if cur_beat != old_beat and cur_beat > old_beat:
		emit_signal("beat_hit")
