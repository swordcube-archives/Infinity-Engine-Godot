extends Node

class_name Modchart

var PlayState

func _ready():
	Conductor.connect("beatHit", self, "beatHit")
	Conductor.connect("stepHit", self, "stepHit")
	
# BEAT HIT AND STEP HIT
func beatHit():
	pass
	
func stepHit():
	pass
	
# OTHER BS

func onOpponentNoteHit(noteData, isSustainNote, noteType):
	pass
	
func onPlayerNoteHit(noteData, isSustainNote, noteType):
	pass
	
func onPopUpScore(rating, noteMS):
	pass
	
func onCountdownTick(counter):
	pass
	
func onStartCountdown():
	pass
	
func onSongStart():
	pass
