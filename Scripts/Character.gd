extends Node2D

class_name Character

var danced:bool = false

var hold_timer = 0

var last_anim:String = ""

onready var PlayState = $"../"

export(Color) var health_color = Color("A1A1A1")
export(Texture) var health_icon = preload("res://Assets/Images/Icons/placeholder.png")
export(bool) var dances_left_right = false
export(float) var sing_duration = 4
export(String) var death_character = "bf-dead"
export(bool) var is_player = false
export(bool) var dances = true

var special_anim = false

onready var anim_player = $anim
onready var frames = $frames

onready var camera_pos:Vector2 = $camera_pos.position

func _ready():
	if is_player:
		scale.x *= -1
		
	if dances:
		dance(true)

func play_anim(anim, force = false):
	if name != "_" and anim_player.get_animation(anim) != null:
		special_anim = false
		last_anim = anim
		
		anim_player.stop()
		
		if frames:
			frames.stop()
		
		anim_player.play(anim)
	
func _process(delta):
	if dances:
		if not is_player:
			if last_anim.begins_with('sing'):
				hold_timer += delta * GameplaySettings.song_multiplier
				
				if hold_timer >= Conductor.step_crochet * sing_duration * 0.001:
					dance(true)
					hold_timer = 0.0
		else:
			if last_anim.begins_with('sing'):
				hold_timer += delta * GameplaySettings.song_multiplier
				
				if hold_timer > Conductor.step_crochet * sing_duration * 0.001 and not PlayState.pressed.has(true):
					if last_anim.begins_with('sing') and not last_anim.ends_with('miss'):
						dance()
			else:
				hold_timer = 0
	
func dance(force = null):
	if force == null:
		force = dances_left_right
	
	if force or anim_player.current_animation == "":
		if dances_left_right:
			danced = not danced
			
			if last_anim.begins_with("singLEFT"):
				danced = true
				
			if last_anim.begins_with("singRIGHT"):
				danced = false
				
			if danced:
				play_anim("danceLeft", force)
			else:
				play_anim("danceRight", force)
		else:
			play_anim("idle", force)
			
func is_dancing():
	var dancing = true
		
	if !last_anim.begins_with("idle") and !last_anim.begins_with("dance"):
		dancing = false
	
	return dancing

func _on_frames_animation_finished():
	if anim_player.has_animation(last_anim + "-loop"):
		play_anim(last_anim + "-loop")
