extends AnimatedSprite

func _process(delta):
	for child in get_children():
		child.position.x = 0.45 - (Conductor.songPosition - child.strumTime) * 1
