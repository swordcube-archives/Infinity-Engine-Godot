extends Node2D

export(bool) var dances_left_right = false

var danced:bool = false

var last_anim:String = ""

func _ready():
	dance(true)

func play_anim(animation):
	if name != "_":
		last_anim = animation
		
		$anim.stop()
		
		if get_node("frames") != null:
			get_node("frames").stop()
		
		$anim.play(animation)

func dance(force = null):
	if force == null:
		force = dances_left_right
	
	if force or $anim.current_animation == "":
		if dances_left_right:
			danced = not danced
			if danced:
				play_anim("danceLeft")
			else:
				play_anim("danceRight")
		else:
			play_anim("idle")
		
func is_dancing():
	var dancing = true
		
	if last_anim != "idle" and !last_anim.begins_with("dance"):
		dancing = false
	
	return dancing
