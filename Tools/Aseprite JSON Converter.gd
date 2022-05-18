extends Panel

onready var path = $Path
onready var button = $Button

onready var sprite_data = $SpriteData

func convert_xml():
	if path.text != "":
		var path_string:String
		
		if path.text.ends_with(".png") or path.text.ends_with(".json"):
			path_string = "res://" + path.text.left(len(path.text) - 4)
		else:
			path_string = "res://" + path.text
		
		if path_string.begins_with("res://res://"):
			path_string = path_string.right(6)
		
		var texture = load(path_string + ".png")
		
		if texture != null:
			var frames = SpriteFrames.new()
			
			var json = File.new()
			json.open(path_string + ".json", File.READ)
			
			sprite_data.frames = frames
			
			var data = JSON.parse(json.get_as_text()).result
			
			for sprite_name in data.frames:
				var animation_name = "frames"
				
				var sprite = data.frames[sprite_name]
				
				var frame_rect = Rect2(
					Vector2(
						int(sprite.frame.x),
						int(sprite.frame.y)
					),
					Vector2(
						int(sprite.frame.w),
						int(sprite.frame.h)
					)
				)
				
				var frame_data = AtlasTexture.new()
				frame_data.atlas = texture
				frame_data.region = frame_rect
				frame_data.flags = Texture.FLAG_MIPMAPS
				frame_data.filter_clip = true
				
				if !frames.has_animation(animation_name):
					frames.add_animation(animation_name)
					frames.set_animation_loop(animation_name, false)
					frames.set_animation_speed(animation_name, floor(1000.0 / sprite.duration))
				
				frames.add_frame(animation_name, frame_data)
			
			frames.remove_animation("default")
			ResourceSaver.save(path_string + ".res", frames, ResourceSaver.FLAG_COMPRESS)
			
			for anim in frames.animations:
				sprite_data.play(anim.name)
				yield(get_tree().create_timer(0.01), "timeout")
		else:
			print(path_string + " loading failed.")
			
func _process(delta):
	if Input.is_action_just_pressed("ui_back"):
		SceneHandler.switch_to("ToolsMenu")
