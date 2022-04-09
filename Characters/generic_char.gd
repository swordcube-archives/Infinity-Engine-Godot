extends Node2D

var danced:bool = false

var hold_timer = 0

var last_anim:String = ""

export(Color) var health_color = Color("A1A1A1")
export(Texture) var health_icon = preload("res://Assets/Images/Icons/placeholder.png")
export(bool) var dances_left_right = false
export(float) var sing_duration = 4
export(String) var death_character = "bf-dead"
export(bool) var is_player = false

var special_anim = false

func _ready():
	dance(true)

func play_anim(anim, force = false):
	if name != "_":
		special_anim = false
		last_anim = anim
		
		$anim.stop()
		
		if get_node("frames") != null:
			get_node("frames").stop()
		
		$anim.play(anim)
	
func _process(delta):
	if not is_player:
		if last_anim.begins_with('sing'):
			hold_timer += delta * Gameplay.song_multiplier
			
			if hold_timer >= Conductor.timeBetweenSteps * sing_duration * 0.001:
				dance(true)
				hold_timer = 0.0
	else:
		if last_anim.begins_with('sing'):
			hold_timer += delta * Gameplay.song_multiplier
		else:
			hold_timer = 0
	
func dance(force = null):
	if force == null:
		force = dances_left_right
	
	if force or $anim.current_animation == "":
		if dances_left_right:
			danced = not danced
				
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
	if $anim.has_animation(last_anim + "-loop"):
		play_anim(last_anim + "-loop")
