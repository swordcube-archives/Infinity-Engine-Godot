extends Node2D

var isSustainNote = false
var mustPress = false

var canBeHit:bool = false
var tooLate:bool = false
var wasGoodHit:bool = false
var strumTime:float = 0.0
var sustainLength:float = 0.0

var noteData:int = 0

var swagWidth:float = 160 * 0.7

var dir_string = "A"

var beingPressed = false
var shouldHit = true

onready var line = $Line2D

func set_direction():
	match(noteData % 4):
		0:
			dir_string = "A"
		1:
			dir_string = "B"
		2:
			dir_string = "C"
		3:
			dir_string = "D"
			
	$Note.play(dir_string)
			
func _process(delta):
	line.modulate.a = 0.6
	$End.modulate.a = 0.6
	
	if get_tree().current_scene.downscroll:
		line.points[1].y = 0 - sustainLength
		$End.position.y = line.points[1].y - ($End.texture.get_height() / 2)
	else:
		line.points[1].y = 0 + sustainLength
		$End.position.y = line.points[1].y + ($End.texture.get_height() / 2)
	
	if get_tree().current_scene.downscroll:
		$End.flip_v = true
	else:
		$End.flip_v = false
		
func calculate_can_be_hit():
	if(mustPress):
		if (isSustainNote):
			if(shouldHit):
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5)):
					canBeHit = true;
				else:
					canBeHit = false;
			else:
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset * 0.3
					&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset * 0.2):
					canBeHit = true;
				else:
					canBeHit = false;
		else:
			if(shouldHit):
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
					&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset):
					canBeHit = true;
				else:
					canBeHit = false;
			else:
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset * 0.3
					&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset * 0.2):
					canBeHit = true;
				else:
					canBeHit = false;

		if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit):
			tooLate = true;
	else:
		canBeHit = false;

		if (strumTime <= Conductor.songPosition):
			wasGoodHit = true;
