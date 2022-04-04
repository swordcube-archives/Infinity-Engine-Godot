extends Node

func _process(delta):
	if self.modulate.a <= 0:
		queue_free()
