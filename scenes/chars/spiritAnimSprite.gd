extends AnimatedSprite

var activated:bool = false

func _process(delta):
	if activated:
		modulate.a -= delta * 0.5
		if modulate.a <= 0:
			queue_free()
