extends AudioStreamPlayer

var isClone:bool = false

func _process(delta):
	if not isClone:
		pass
		
	if not stream.loop:
		if get_playback_position() >= stream.get_length():
			stop()
			queue_free()
