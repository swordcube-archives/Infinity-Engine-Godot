extends Node2D

export(String) var direction = "A"
export(StreamTexture) var sustain_tex = null
export(StreamTexture) var sustain_end_tex = null
export(bool) var should_hit = true

onready var spr = $spr
onready var charter_sustain = $CharterSustain
onready var line2d = $Line2D

onready var rect = $ColorRect
onready var end = $ColorRect/End

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

var downscroll:bool = false

var being_pressed:bool = false

# used for opponent notes :D
var hit_already:bool = false

var can_be_hit:bool = false
var too_late:bool = false
var was_good_hit:bool = false

func _ready():
	line2d.position.x -= 2.5
	rect.rect_position.x -= 2.5
	
	match Options.get_data("sustain-clipping-style"):
		"StepMania":
			line2d.z_index = -1
			end.z_index = -1
			
	if !spr.frames:
		spr.frames = GameplaySettings.ui_skin.note_tex
		
	play_anim("")
	
func _process(delta):
	var y_pos = ((sustain_length / 1.5) * GameplaySettings.scroll_speed) / (scale.y + 0.3)
	var fixed_y_pos = max(((sustain_length / 1.5) * GameplaySettings.scroll_speed) / (scale.y + 0.3), 0)
	
	if not charter_note:
		if downscroll:
			line2d.points[1].y = 0 - fixed_y_pos
			end.flip_v = true
			if sustain_length <= 0:
				rect.rect_position.y = -70
				end.position.y = 45 + ((0 - y_pos) - (end.texture.get_height() / 2))
			else:
				rect.rect_position.y = (0 - y_pos) - (end.texture.get_height() * 1.2)
				end.position.y = 45
		else:
			line2d.points[1].y = fixed_y_pos
			if sustain_length <= 0:
				rect.rect_position.y = -70
				end.position.y = 45 + (y_pos + (end.texture.get_height() / 2))
			else:
				rect.rect_position.y = y_pos - (end.texture.get_height() * 1.2)
				end.position.y = 45
	else:
		end.visible = false

func play_anim(anim):
	# check if the note is animated lol
	if spr is AnimatedSprite:
		match anim:
			"":
				spr.play(direction)
			_:
				spr.play(anim)
			
func load_sus_texture():
	if GameplaySettings.ui_skin.sustain_tex:
		line2d.texture = load(GameplaySettings.ui_skin.sustain_tex.replace("hold.png", direction + " hold.png"))
		
	if GameplaySettings.ui_skin.sustain_end_tex:
		end.texture = load(GameplaySettings.ui_skin.sustain_end_tex.replace("tail.png", direction + " tail.png"))
		
	if sustain_tex:
		line2d.texture = sustain_tex
		
	if sustain_end_tex:
		end.texture = sustain_end_tex
		
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
