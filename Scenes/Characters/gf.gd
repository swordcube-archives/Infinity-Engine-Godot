extends Character

func play_anim(anim, force = false):
	$speakers.stop()
	$speakers.frame = 0
	$speakers.play("bop")
	
	if name != "_" and anim_player.get_animation(anim) != null:
		special_anim = false
		last_anim = anim
		
		anim_player.stop()
		
		if frames:
			frames.stop()
		
		anim_player.play(anim)
	
func dance(force = null):
	danced = not danced
	
	if last_anim.begins_with("singLEFT"):
		danced = true
		
	if last_anim.begins_with("singRIGHT"):
		danced = false
		
	if danced:
		play_anim("danceLeft", force)
	else:
		play_anim("danceRight", force)
