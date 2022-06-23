extends AudioStreamPlayer

var isClone:bool = false

func _process(delta):
	if isClone and not stream.loop:
		if get_playback_position() >= stream.get_length():
			stop()
			queue_free()
