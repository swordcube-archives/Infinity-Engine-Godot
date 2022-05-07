extends Character

func play_anim(anim, force = false):
	# godot shits itself if i use variables here :D
	
	$speakers.play("bop")
	
	if name != "_" and $anim.get_animation(anim) != null:
		special_anim = false
		last_anim = anim
		
		$anim.stop()
		
		if $girl:
			$girl.stop()
		
		$anim.play(anim)
