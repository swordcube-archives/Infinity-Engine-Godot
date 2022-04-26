extends Node2D

onready var columns = 8
onready var rows = 16

var grid_size = 40

var selected_x = 0
var selected_y:float = 0.0

var note_snap = 16

var og_pos_x = 0.0

# events array
var events = []

var selected_event = null
var selected_note = null

var selected_event_object = null
var selected_note_object = null

var ctrl_pressed = false

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_CONTROL:
			ctrl_pressed = event.pressed

func _ready():
	og_pos_x = position.x
	
	if "events" in Gameplay.SONG.song:
		events = Gameplay.SONG.song.events

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
	columns = Gameplay.SONG.song.keyCount * 2
	
	position.x = og_pos_x - ((Gameplay.SONG.song.keyCount - 4) * grid_size) * 2
	
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
			AudioHandler.play_hitsound("osu!")
	
	var cool_grid = grid_size / (note_snap / 16.0)
	
	if Input.is_action_pressed("ui_shift"):
		$Selected.rect_position = Vector2(selected_x * grid_size, mouse_pos.y)
	else:
		$Selected.rect_position = Vector2(selected_x * grid_size, floor(mouse_pos.y / cool_grid) * cool_grid)
		
	#if prev_selected_x != selected_x or prev_selected_y != selected_y:
	update()
		
	if Input.is_action_just_pressed("mouse_left"):
		if selected_x >= 0 and selected_x <= columns:
			if selected_y >= 0 and selected_y < rows:
				if ctrl_pressed:
					select_note(selected_x, selected_y)
				else:
					add_note(selected_x, selected_y)
				print("PLACED NOTE!")
		
func load_section(section):
	for note in $Notes.get_children():
		note.free()
		
	for event in $Events.get_children():
		event.free()
		
	if Gameplay.SONG.song.notes[section] == null:
		Gameplay.SONG.song.notes.append({
			"sectionNotes": [],
			"lengthInSteps": 16,
			"mustHitSection": true
		})
		
	for event in events:
		spawn_event(time_to_y(event[0] - section_start_time()), time_to_y(event[0] - section_start_time()), event[0], event[1])
		
	for note in Gameplay.SONG.song.notes[section].sectionNotes:
		spawn_note(note[1] + 1, time_to_y(note[0] - section_start_time()), time_to_y(note[0] - section_start_time()), note[0], note[2], note[3])
		
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
	
func select_note(x, y):
	var mouse_pos = get_global_mouse_position()
	mouse_pos.x -= position.x
	mouse_pos.y -= position.y
	
	# selecting notes
	for note in $Notes.get_children():
		if selected_x * grid_size == note.position.x:
			if mouse_pos.y >= note.position.y and mouse_pos.y <= note.position.y + grid_size:
				for note_object in Gameplay.SONG.song.notes[$"../".curSection].sectionNotes:
					if note_object[1] == int(x - 1):
						if int(note_object[0]) == int(y_to_time(note.position.y) + section_start_time()):
							selected_note = note_object
							print("SELECTED NOTE!")
				
				selected_note_object = note
				return
				
	# selecting events
	for event in $Events.get_children():
		if selected_x * grid_size == event.position.x:
			if mouse_pos.y >= event.position.y and mouse_pos.y <= event.position.y + grid_size:
				for note_object in events:
					if int(note_object[0]) == int(y_to_time(event.position.y) + section_start_time()):
						selected_event = note_object
						$"../Tabs/Events/Event/EventDropdown".text = note_object[1][0][0]
						$"../Tabs/Events/Value1/Value1Input".text = note_object[1][0][1]
						$"../Tabs/Events/Value2/Value2Input".text = note_object[1][0][2]
						print("SELECTED EVENT!")
				
				selected_event_object = event
				return
				
func add_note(x, y):
	var mouse_pos = get_global_mouse_position()
	mouse_pos.x -= position.x
	mouse_pos.y -= position.y
	
	# deleting notes
	for note in $Notes.get_children():
		if selected_x * grid_size == note.position.x:
			if mouse_pos.y >= note.position.y and mouse_pos.y <= note.position.y + grid_size:
				for note_object in Gameplay.SONG.song.notes[$"../".curSection].sectionNotes:
					if note_object[1] == int(x - 1):
						if int(note_object[0]) == int(y_to_time(note.position.y) + section_start_time()):
							Gameplay.SONG.song.notes[$"../".curSection].sectionNotes.erase(note_object)
				
				note.queue_free()
				return
				
	# deleting events
	for event in $Events.get_children():
		if selected_x * grid_size == event.position.x:
			if mouse_pos.y >= event.position.y and mouse_pos.y <= event.position.y + grid_size:
				for note_object in events:
					if int(note_object[0]) == int(y_to_time(event.position.y) + section_start_time()):
						events.erase(note_object)
				
				event.queue_free()
				return
				
	var strum_time = y_to_time($Selected.rect_position.y) + section_start_time()
	var note_data = int(x - 1)
	var note_length = 0.0
	var sustain_length = 0.0
	var note_type = $"../Tabs/Notes/NoteType/NoteTypeDropdown".text
	
	if note_data < 0:
		var event_name = $"../Tabs/Events/Event/EventDropdown".text
		var value1 = $"../Tabs/Events/Value1/Value1Input".text
		var value2 = $"../Tabs/Events/Value2/Value2Input".text
		
		var events_array = [[event_name, value1, value2]]
		
		var piss = spawn_event(y, null, strum_time, events_array)
		
		var balls = [strum_time, events_array]
		events.append(balls)
		
		selected_event = balls
		selected_event_object = piss
	else:
		var balls = spawn_note(x, y, null, strum_time, sustain_length, note_type)
		
		var bitch = [strum_time, note_data, note_length, note_type]
		
		Gameplay.SONG.song.notes[$"../".curSection].sectionNotes.append(bitch)
		selected_note = bitch
		selected_note_object = balls
		
func spawn_event(y, custom_y = null, strum_time = 0, events_array = []):
	if custom_y == null:
		custom_y = $Selected.rect_position.y
	
	var mouse_pos = get_global_mouse_position()
	mouse_pos.x -= position.x
	mouse_pos.y -= position.y
	
	var new_note = load("res://Scenes/Notes/EventNote.tscn").instance()
	new_note.position = Vector2(0, custom_y)
	new_note.strumTime = strum_time
	new_note.events = events
	
	new_note.scale.x = 40.0 / new_note.texture.get_width()
	new_note.scale.y = 40.0 / new_note.texture.get_height()
	
	$Events.add_child(new_note)
	
func spawn_note(x, y, custom_y = null, strum_time = 0, sustain_length = 0, note_type = "Default"):
	if custom_y == null:
		custom_y = $Selected.rect_position.y
	
	var mouse_pos = get_global_mouse_position()
	mouse_pos.x -= position.x
	mouse_pos.y -= position.y
	
	var loaded_note = load("res://Scenes/Notes/" + note_type + "/Note.tscn")
	if loaded_note == null:
		loaded_note = load("res://Scenes/Notes/Default/Note.tscn")
		
	var new_note = loaded_note.instance()
	new_note.position = Vector2(x * grid_size, custom_y)
	new_note.noteData = int(x - 1)
	new_note.charter_note = true
	new_note.strumTime = strum_time
	new_note.sustainLength = sustain_length #- (grid_size * 1.5)
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
	return new_note
			
func draw_box(x, y, is_dark):
	var cool_color = Color(0.9, 0.9, 0.9)
	
	if is_dark:
		cool_color = Color(0.835, 0.835, 0.835)
	
	draw_rect(Rect2(Vector2(x * grid_size, y * grid_size), Vector2(grid_size, grid_size)), cool_color, true)
