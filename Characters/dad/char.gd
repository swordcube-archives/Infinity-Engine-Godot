extends Node2D

var danced:bool = false

export(Color) var health_color
export(Texture) var health_icon
export(int) var camera_pos_x = 0
export(int) var camera_pos_y = 0

func play_anim(anim):
	$anim.play(anim)
	
func dance():
	if $anim.get("danceLeft") != null and $anim.get("danceRight") != null:
		if danced:
			$anim.play("danceLeft")
		else:
			$anim.play("danceRight")
			
		danced = not danced
	else:
		$anim.play("idle")
