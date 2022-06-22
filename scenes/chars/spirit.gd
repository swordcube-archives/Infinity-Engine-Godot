extends Character

func _ready():
	if isPlayer:
		scale.x *= -1
		
	if dances:
		dance(true)
		
	initFrame = frames.frames.get_frame(frames.animation, frames.frame)
	
	while true:
		yield(get_tree().create_timer(0.2),"timeout")
		var trailCopy = $AnimatedSprite.duplicate()
		trailCopy.modulate.a = 0.4
		trailCopy.activated = true
		$trails.add_child(trailCopy)
