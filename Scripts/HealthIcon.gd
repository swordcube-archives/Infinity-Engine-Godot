extends Sprite

var old_texture = null

func _process(delta):
	if not old_texture == texture:
		old_texture = texture
		
		hframes = 3
		
		if texture.get_width() == texture.get_height() * 2:
			hframes = 2
			
		if texture.get_width() == texture.get_height():
			hframes = 1
			
func switch_to(state = "normal"):
	match hframes:
		3:
			match state:
				"losing":
					frame = 1
				"winning":
					frame = 2
				"normal", _:
					frame = 0
		2:
			match state:
				"losing":
					frame = 1
				"winning", "normal", _:
					frame = 0
		1:
			frame = 0
