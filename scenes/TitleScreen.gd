extends Node2D

onready var logo = $logo
onready var gfDance = $gfDance
onready var titleText = $titleText

func _ready():
	Conductor.songPosition = 0.0
	Conductor.changeBPM(102)
	Conductor.connect("beatHit", self, "beatHit")
	titleText.play("idle")
	
func _process(delta):
	Conductor.songPosition += (delta * 1000)
	
var danced:bool = false
func beatHit():
	logo.frame = 0
	logo.play("bump")
	danced = !danced
	if danced:
		gfDance.frame = 0
		gfDance.play("danceLeft")
	else:
		gfDance.frame = 0
		gfDance.play("danceRight")
