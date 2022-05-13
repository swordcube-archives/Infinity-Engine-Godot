extends Node2D

class_name StoryCharacter

export(bool) var dances_left_right:bool = false

onready var anim = $anim
onready var frames = $frames

var last_anim:String = ""

var danced:bool = false

func dance():
	danced = not danced
	
	if dances_left_right:
		if frames:
			frames.stop()
			
		if anim:
			if danced:
				play_anim("danceLeft")
			else:
				play_anim("danceRight")
	else:
		if frames:
			frames.stop()
			
		if anim:
			play_anim("idle")
			
func is_dancing():
	var dancing = true
		
	if last_anim == "confirm":
		dancing = false
	
	return dancing
			
func play_anim(name):
	if name != "_" and anim.get_animation(name) != null:
		last_anim = name
		anim.play(name)
