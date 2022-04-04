extends Node2D

var danced:bool = false

var hold_timer = 0

export(Color) var health_color
export(Texture) var health_icon
export(bool) var dances_left_right
#export(int) var camera_pos_x = 0
#export(int) var camera_pos_y = 0
export(float) var sing_duration = 6.1
export(bool) var is_player = false

func play_anim(anim, force = false):
	if not $anim.current_animation == anim or ($anim.current_animation == anim and $anim.is_playing()) or force:
		$frames.frame = 0
		
	$anim.play(anim)
	
func _process(delta):
	print($anim.current_animation.begins_with('sing'))
	if not is_player:
		if $anim.current_animation.begins_with('sing'):
			hold_timer += delta

		if hold_timer >= Conductor.timeBetweenSteps * 0.001 * sing_duration:
			dance()
			hold_timer = 0	
	
func dance():
	if dances_left_right:
		if danced:
			$anim.play("danceLeft")
		else:
			$anim.play("danceRight")
			
		danced = not danced
	else:
		$anim.play("idle")
