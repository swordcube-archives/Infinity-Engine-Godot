extends Sprite

onready var PlayState = get_node("../../../")
var icons = 3

var old_texture = null

func _process(delta):
	if not old_texture == texture:
		old_texture = texture
		if texture.get_width() / 2 > PlayState.dad.icon_size.x:
			hframes = 3
		else:
			hframes = 2
		
		if texture.get_width() == PlayState.dad.icon_size.x:
			hframes = 1
		
func switch_to(type):
	match type:
		"winning":
			match hframes:
				3:
					frame = 2
				2:
					frame = 0
				_:
					frame = 0
		"losing":
			match hframes:
				3, 2:
					frame = 1
				_:
					frame = 0
		_:
			frame = 0
