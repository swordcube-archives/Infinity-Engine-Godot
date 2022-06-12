extends Node

var songPosition:float = 0.0
var bpm:float = 100.0
var speed:float = 1.0

var timeBetweenBeats:float = ((60 / bpm) * 1000)
var timeBetweenSteps:float = timeBetweenBeats / 4

var curBeat:int = 0
var curStep:int = 0

# basically amount of MS you can have for safe frames
var safeZoneOffset:float = 166

# funny array of [position_in_song, bpm, step_change_is_at]
var bpmChanges:Array = []

signal beatHit
signal stepHit

func _process(_delta):
	var oldBeat = curBeat
	var oldStep = curStep

	var lastChange:Array = [0,0,0]
	
	for change in bpmChanges:
		if songPosition >= change[0]:
			lastChange = change
			
			bpm = change[1]
			recalculateValues()
		else:
			break
	
	if len(lastChange) < 3:
		lastChange.append(0)
	
	curStep = lastChange[2] + floor((songPosition - lastChange[0]) / timeBetweenSteps)
	curBeat = floor(curStep / 4)
	
	if curStep != oldStep and curStep > oldStep:
		emit_signal("stepHit")
	if curBeat != oldBeat and curBeat > oldBeat:
		emit_signal("beatHit")

func recalculateValues():
	timeBetweenBeats = ((60 / bpm) * 1000)
	timeBetweenSteps = timeBetweenBeats / 4

func change_bpm(newBPM, changes = []):
	if len(changes) == 0:
		changes = [[0, newBPM, 0]]
	
	bpmChanges = changes
	bpm = newBPM
	recalculateValues()

func mapBPMChanges(songData):
	var changes = []
	
	var curBPM:float = songData["bpm"]
	var totalSteps:int = 0
	var totalPos:float = 0.0
	
	for section in songData["notes"]:
		if "changeBPM" in section:
			if section["changeBPM"] and section["bpm"] != curBPM and section["bpm"] > 0:
				curBPM = section["bpm"]
				
				var change = [totalPos, section["bpm"], totalSteps]
				
				changes.append(change)
		
		if not "lengthInSteps" in section:
			section["lengthInSteps"] = 16
		
		var sectionLength:int = section["lengthInSteps"]
		
		totalSteps += sectionLength
		totalPos += ((60 / curBPM) * 1000 / 4) * sectionLength
	
	return changes
