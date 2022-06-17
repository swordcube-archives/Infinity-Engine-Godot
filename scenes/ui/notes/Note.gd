extends Node2D

class_name Note

var downScroll:bool = false

onready var spr = $spr

export(String) var direction:String = "A"
export(float) var strumTime:float = 0.0

var mustPress:bool = false

var noteData:int = 0

var isSustainNote:bool = false
var isEndOfSustain:bool = false

var timeBetweenBeats:float = Conductor.timeBetweenBeats
var timeBetweenSteps:float = Conductor.timeBetweenSteps

func _ready():
	if spr.frames == CoolUtil.nullRes:
		spr.frames = PlayStateSettings.currentUiSkin.note_tex
		
	var ss = PlayStateSettings.currentUiSkin.strum_scale
	spr.scale = Vector2(ss, ss)
		
	refreshAnim()

func refreshAnim():
	var a = direction
	if isSustainNote:
		if not isEndOfSustain:
			a += " hold"
		else:
			a += " tail"
	
	spr.play(a)
	if isEndOfSustain:
		if downScroll:
			spr.centered = false
			
		spr.flip_v = downScroll
