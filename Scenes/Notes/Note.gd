extends Node2D

onready var PlayState = null

# for funnies
export(float) var dad_health_gain = 0
export(float) var bf_health_gain = 0.023
export(float) var hit_damage = 0.0
export(float) var miss_damage = 0.0475
export(bool) var shouldHit = true

var isSustainNote = false
var mustPress = false

var canBeHit:bool = false
var tooLate:bool = false
var wasGoodHit:bool = false
var strumTime:float = 0.0

var old_sus:float = 0.0
var sustainLength:float = 0.0

var noteData:int = 0

var swagWidth:float = 160 * 0.7

var dir_string = "A"

var beingPressed = false

var isGaming = false

var charter_note = false

onready var line = $Line2D

func set_direction():
	old_sus = sustainLength
	
	dir_string = Gameplay.note_letter_directions[Gameplay.key_count - 1][noteData % Gameplay.key_count]
			
	$Note.play(dir_string)
			
func _process(delta):
	if not charter_note:
		PlayState = get_parent().get_parent().get_parent()
		
	if not charter_note:
		line.modulate.a = 0.6
		$End.modulate.a = 0.6
		
		var y_pos = (sustainLength / 1.5) * Gameplay.scroll_speed
		y_pos -= $Line2D.texture.get_height()
		
		if get_tree().current_scene.downscroll:
			line.points[1].y = 0 - y_pos
			$End.position.y = line.points[1].y - ($End.texture.get_height() / 2)
		else:
			line.points[1].y = 0 + y_pos
			$End.position.y = line.points[1].y + ($End.texture.get_height() / 2)
		
		if get_tree().current_scene.downscroll:
			$End.flip_v = true
		else:
			$End.flip_v = false
			
		if line.points[1].y <= 0:
			$End.region_rect.size.y -= delta
	else:
		line.points[1].y = 0 + sustainLength
		
func opponent_note_hit():
	PlayState.health -= dad_health_gain
	
func player_note_hit():
	PlayState.health += bf_health_gain
	PlayState.health -= hit_damage
	
func player_note_miss():
	PlayState.health -= miss_damage
		
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
