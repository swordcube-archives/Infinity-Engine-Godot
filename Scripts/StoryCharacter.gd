extends Node2D

class_name StoryCharacter

export(bool) var dances_left_right:bool = false

onready var anim_player = $anim
onready var frames = $frames

var last_anim:String = ""

var danced:bool = false

func dance():
	danced = not danced
	
	if dances_left_right:
		if danced:
			play_anim("danceLeft")
		else:
			play_anim("danceRight")
	else:
		play_anim("idle")
			
func is_dancing():
	var dancing = true
		
	if !last_anim.begins_with("idle") and !last_anim.begins_with("dance"):
		dancing = false
	
	return dancing
			
func play_anim(anim, force = false):
	if name != "_" and anim_player.get_animation(anim) != null:
		last_anim = anim
		
		anim_player.stop()
		
		if frames:
			frames.stop()
		
		anim_player.play(anim)
