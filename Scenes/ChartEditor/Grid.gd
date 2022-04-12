extends Node2D

var columns = 8
var rows = 16

var grid_size = 40

var selected_x = 0
var selected_y:float = 0.0

var note_snap = 16

func _draw():
	var dark = false
	
	for x in columns + 1:
		dark = !dark
		
		if (x * grid_size) + position.x > 1280:
			break
		if (x * grid_size) + position.x < 0 - grid_size:
			continue
		
		for y in rows:
			draw_box(x,y,dark)
			
			dark = !dark
			
			if (y * grid_size) + position.y > 720:
				break
			if (y * grid_size) + position.y < 0 - grid_size:
				continue
				
	# separators
	var c = (columns / 2) + 1
	draw_rect(Rect2(Vector2(grid_size, position.y - grid_size), Vector2(2, rows * grid_size)), Color("000000"), true)
	draw_rect(Rect2(Vector2(c * grid_size, position.y - grid_size), Vector2(2, rows * grid_size)), Color("000000"), true)
				
func _process(_delta):
	$Line.rect_size.x = grid_size * (columns + 1)
	$Line.rect_position.y = time_to_y(Conductor.songPosition - section_start_time())
	
	var prev_selected_x = selected_x
	var prev_selected_y = selected_y
	
	var mouse_pos = get_global_mouse_position()
	mouse_pos.x -= position.x
	mouse_pos.y -= position.y
	
	selected_x = floor(mouse_pos.x / grid_size)
	selected_y = floor(mouse_pos.y / grid_size)
	
	for note in $Notes.get_children():
		if Conductor.songPosition >= note.strumTime:
			note.modulate.a = 0.4
			note.strumTime = 9999999
			AudioHandler.play_hitsound(Options.get_data("hitsound"))
	
	var cool_grid = grid_size / (note_snap / 16.0)
	
	if Input.is_action_pressed("shift"):
		$Selected.rect_position = Vector2(selected_x * grid_size, mouse_pos.y)
	else:
		$Selected.rect_position = Vector2(selected_x * grid_size, floor(mouse_pos.y / cool_grid) * cool_grid)
		
	if prev_selected_x != selected_x or prev_selected_y != selected_y:
		update()
		
	if Input.is_action_just_pressed("mouse_left"):
		if selected_x >= 0 and selected_x <= columns:
			if selected_y >= 0 and selected_y < rows:
				add_note(selected_x, selected_y)
				print("PLACED NOTE!")
		
func load_section(section):
	for note in $Notes.get_children():
		note.free()
		
	if Gameplay.SONG.song.notes[section] == null:
		Gameplay.SONG.song.notes.append({
			"sectionNotes": [],
			"lengthInSteps": 16,
			"mustHitSection": true
		})
		
	for note in Gameplay.SONG.song.notes[section].sectionNotes:
		spawn_note(note[1] + 1, time_to_y(note[0] - section_start_time()), time_to_y(note[0] - section_start_time()), note[0], note[2])
		
func section_start_time(section = null):
	if section == null:
		section = $"../".curSection
	
	var coolPos:float = 0.0
	
	var good_bpm = Conductor.bpm
	
	for i in section:
		if "changeBPM" in Gameplay.SONG.song.notes[i]:
			if Gameplay.SONG.song.notes[i]["changeBPM"] == true:
				good_bpm = Gameplay.SONG.song.notes[i]["bpm"]
		
		coolPos += 4 * (1000 * (60 / good_bpm))
	
	return coolPos
	
func y_to_time(y):
	return range_lerp(y + grid_size, position.y, position.y + (rows * grid_size), 0, 16 * Conductor.timeBetweenSteps)
		
func time_to_y(time):
	return range_lerp(time - Conductor.timeBetweenSteps, 0, 16 * Conductor.timeBetweenSteps, position.y, position.y + (rows * grid_size))
				
func add_note(x, y):
	var mouse_pos = get_global_mouse_position()
	mouse_pos.x -= position.x
	mouse_pos.y -= position.y
	
	for note in $Notes.get_children():
		if selected_x * grid_size == note.position.x:
			if mouse_pos.y >= note.position.y and mouse_pos.y <= note.position.y + grid_size:
				for note_object in Gameplay.SONG.song.notes[$"../".curSection].sectionNotes:
					if note_object[1] == int(x - 1):
						if int(note_object[0]) == int(y_to_time(note.position.y) + section_start_time()):
							Gameplay.SONG.song.notes[$"../".curSection].sectionNotes.erase(note_object)
				
				note.queue_free()
				return
				
	var strum_time = y_to_time($Selected.rect_position.y) + section_start_time()
	var note_data = int(x - 1)
	var note_length = 0.0
	var sustain_length = 0.0
	
	spawn_note(x, y, null, strum_time, sustain_length)
	
	Gameplay.SONG.song.notes[$"../".curSection].sectionNotes.append([strum_time, note_data, note_length])
	
func spawn_note(x, y, custom_y = null, strum_time = 0, sustain_length = 0):
	if custom_y == null:
		custom_y = $Selected.rect_position.y
	
	var mouse_pos = get_global_mouse_position()
	mouse_pos.x -= position.x
	mouse_pos.y -= position.y
	
	var new_note = load("res://Scenes/Notes/" + $"../".note_type + "/Note.tscn").instance()
	new_note.position = Vector2(x * grid_size, custom_y)
	new_note.noteData = int(x - 1)
	new_note.charter_note = true
	new_note.strumTime = strum_time
	new_note.sustainLength = sustain_length - (grid_size * 1.5)
	new_note.set_direction()
	
	var anim_spr = new_note.get_node("Note")
	var line_2d = new_note.get_node("Line2D")
	var end = new_note.get_node("End")
	
	anim_spr.centered = false
	
	line_2d.position.x += grid_size * 2
	line_2d.position.y += grid_size * 2
	
	if sustain_length <= 0:
		line_2d.visible = false
	
	line_2d.scale.x = 0.8
	line_2d.modulate.r = 9999
	line_2d.modulate.g = 9999
	line_2d.modulate.b = 9999
	
	end.visible = false
	
	new_note.scale.x = 40.0 / anim_spr.frames.get_frame(anim_spr.animation, anim_spr.frame).get_width()
	new_note.scale.y = 40.0 / anim_spr.frames.get_frame(anim_spr.animation, anim_spr.frame).get_height()
	
	$Notes.add_child(new_note)
			
func draw_box(x, y, is_dark):
	var cool_color = Color(0.9, 0.9, 0.9)
	
	if is_dark:
		cool_color = Color(0.835, 0.835, 0.835)
	
	draw_rect(Rect2(Vector2(x * grid_size, y * grid_size), Vector2(grid_size, grid_size)), cool_color, true)
