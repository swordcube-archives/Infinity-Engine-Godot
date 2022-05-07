extends Node2D

export(String) var direction = "A"
export(StreamTexture) var sustain_tex = null
export(StreamTexture) var sustain_end_tex = null
export(bool) var should_hit = true

onready var spr = $spr
onready var line2d = $Line2D
onready var end = $End

onready var PlayState = $"../../../../"

var note_type:String = "Default"
var must_press:bool = false
var og_sustain_length:float = 0.0
var sustain_length:float = 0.0
var strum_time:float = 0.0
var note_data:int = 0
var is_alt:bool = false
var character:String = ""
var charter_note:bool = false

var being_pressed:bool = false

var can_be_hit:bool = false
var too_late:bool = false
var was_good_hit:bool = false

func _ready():
	play_anim("")
	
func _process(delta):
	var y_pos = ((sustain_length / 1.5) * GameplaySettings.scroll_speed) / (scale.y + 0.3)
	if PlayState.downscroll:
		line2d.points[1].y = 0 - y_pos
		end.flip_v = true
		end.position.y = line2d.points[1].y - (end.texture.get_height() / 2)
	else:
		line2d.points[1].y = y_pos
		end.position.y = line2d.points[1].y + (end.texture.get_height() / 2)

func play_anim(anim):
	# check if the note is animated lol
	if $spr is AnimatedSprite:
		match anim:
			"":
				$spr.play(direction)
			_:
				$spr.play(anim)
			
func load_sus_texture():
	if GameplaySettings.ui_skin.sustain_tex:
		$Line2D.texture = load(GameplaySettings.ui_skin.sustain_tex.replace("hold.png", direction + " hold.png"))
		
	if GameplaySettings.ui_skin.sustain_end_tex:
		$End.texture = load(GameplaySettings.ui_skin.sustain_end_tex.replace("tail.png", direction + " tail.png"))
		
	if sustain_tex:
		$Line2D.texture = sustain_tex
		
	if sustain_end_tex:
		$End.texture = sustain_end_tex
		
func calculate_can_be_hit():
	if(must_press):
		if(should_hit):
			if (strum_time > Conductor.song_position - Conductor.safe_zone_offset
				&& strum_time < Conductor.song_position + Conductor.safe_zone_offset):
				can_be_hit = true;
			else:
				can_be_hit = false;
		else:
			if (strum_time > Conductor.song_position - Conductor.safe_zone_offset * 0.3
				&& strum_time < Conductor.song_position + Conductor.safe_zone_offset * 0.2):
				can_be_hit = true;
			else:
				can_be_hit = false;

		if (strum_time < Conductor.song_position - Conductor.safe_zone_offset && !was_good_hit):
			too_late = true;
	else:
		can_be_hit = false;

		if (strum_time <= Conductor.song_position):
			was_good_hit = true;
