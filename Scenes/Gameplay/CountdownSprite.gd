extends Sprite

func _process(delta):
	if texture.resource_path.split(".png")[0].ends_with("-pixel"):
		scale = Vector2(6, 6)
	else:
		scale = Vector2(0.8, 0.8)
		
	if modulate.a <= 0:
		queue_free()
