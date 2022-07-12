extends Node2D

export(int) var rows = 16
export(int) var columns = 8

export(int) var grid_size = 40

var note_snap:int = 16

var selected_x:int = 0
var selected_y:float = 0.0

var curSection:int = 0

onready var charter = $"../"
onready var selected = $ColorRect
onready var notes = $Notes

func _process(delta):
	update()
	
	var mouse_pos = get_global_mouse_position()
	mouse_pos.x -= position.x
	mouse_pos.y -= position.y
	
	selected_x = floor(mouse_pos.x / grid_size)
	selected_y = floor(mouse_pos.y / grid_size)
	
	var cool_grid = grid_size / (note_snap / 16.0)
	
	selected.rect_size = Vector2(grid_size, grid_size)
	
	if Input.is_action_pressed("ui_shift"):
		selected.rect_position = Vector2(selected_x * grid_size, mouse_pos.y)
	else:
		selected.rect_position = Vector2(selected_x * grid_size, floor(mouse_pos.y / cool_grid) * cool_grid)

	if selected_x < 0 or selected_x > columns or selected_y < 0 or selected_y > rows-1:
		selected.visible = false
	else:
		selected.visible = true
		
	if Input.is_action_just_pressed("mouse_left"):
		if selected.visible:
			var note = add_note(selected_x, selected_y)
		
func loadSection():
	for note in notes.get_children():
		note.free()
	
	if not curSection in charter.SONG.notes:
		charter.SONG.notes.append({
			"sectionNotes": [],
			"lengthInSteps": 16,
			"mustHitSection": charter.SONG.notes[charter.SONG.notes.size() - 1].mustHitSection
		})
	
	for note in charter.SONG.notes[curSection].sectionNotes:
		spawn_note(note[1] + 1, time_to_y(note[0] - section_start_time()), time_to_y(note[0] - section_start_time()), note[2])
	
	update()
	
func add_note(x, y):
	var mouse_pos = get_global_mouse_position()
	mouse_pos.x -= position.x
	mouse_pos.y -= position.y
	
	for note in notes.get_children():
		if selected_x * grid_size == note.position.x:
			if mouse_pos.y >= note.position.y and mouse_pos.y <= note.position.y + grid_size:
				for note_object in charter.SONG.notes[curSection].sectionNotes:
					if note_object[1] == int(x - 1):
						if int(note_object[0]) == int(y_to_time(note.position.y) + section_start_time()):
							charter.SONG.notes[curSection].sectionNotes.erase(note_object)
				
				note.queue_free()
				return
	
	var note = spawn_note(x, y, null, 0)
	#note.modulate.a = 0.5
	
	var strum_time = y_to_time(selected.rect_position.y) + section_start_time()
	var note_data = int(x - 1)
	var note_length = 0.0
	
	charter.SONG.notes[curSection].sectionNotes.append([strum_time, note_data, note_length])
	
	return charter.SONG.notes[curSection].sectionNotes[len(charter.SONG.notes[curSection].sectionNotes) - 1]

func spawn_note(x, y, custom_y = null, sustain_length:float = 0.0):
	if custom_y == null:
		custom_y = selected.rect_position.y
	
	var mouse_pos = get_global_mouse_position()
	mouse_pos.x -= position.x
	mouse_pos.y -= position.y
	
	var new_note = load("res://scenes/ui/charter/CharterNote.tscn").instance()
	new_note.position = Vector2(x * grid_size, custom_y)
	
	var key_count:int = 4
	
	if "keyCount" in charter.SONG:
		key_count = int(charter.SONG["keyCount"])
	
	var anim_spr = new_note.get_node("spr")
	anim_spr.play(CoolUtil.dirToStr(int(x - 1) % key_count))
	anim_spr.offset = Vector2(grid_size*2, grid_size*2)
	new_note.scale.y = 40.0 / anim_spr.frames.get_frame(anim_spr.animation, anim_spr.frame).get_height()
	new_note.scale.x = new_note.scale.y
	
	var sustain = new_note.get_node("Sustain")
	sustain.visible = true
	sustain.rect_position += Vector2(grid_size*2, grid_size*2)
	sustain.rect_size.y = floor(range_lerp(sustain_length, 0, Conductor.timeBetweenSteps * 16, 0, rows * grid_size)) / new_note.scale.y
	
	notes.add_child(new_note)
	
	return new_note
	
func y_to_time(y):
	return range_lerp(y + grid_size, position.y, position.y + (rows * grid_size), 0, 16 * Conductor.timeBetweenSteps)

func time_to_y(time):
	return range_lerp(time - Conductor.timeBetweenSteps, 0, 16 * Conductor.timeBetweenSteps, position.y, position.y + (rows * grid_size))

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
			
			"""if (y * grid_size) + position.y > 720:
				break
			if (y * grid_size) + position.y < 0 - grid_size:
				continue"""
				
		if x == 1 or x == floor(columns/1.5):
			draw_rect(Rect2(Vector2(x * grid_size, 0), Vector2(2, rows * grid_size)), Color("#000000"), true)
				
func section_start_time(section = null):
	if section == null:
		section = curSection
	
	var coolPos:float = 0.0
	
	var good_bpm = charter.SONG["bpm"]
	
	for i in section:
		if "changeBPM" in charter.SONG.notes[i]:
			if charter.SONG.notes[i]["changeBPM"] == true and charter.SONG.notes[i]["bpm"] > 0:
				good_bpm = charter.SONG.notes[i]["bpm"]
		
		coolPos += 4.0 * (1000.0 * (60.0 / good_bpm))
	
	return coolPos
				
func draw_box(x, y, is_dark):
	var cool_color = Color(0.9, 0.9, 0.9)
	
	if is_dark:
		cool_color = Color(0.835, 0.835, 0.835)
	
	draw_rect(Rect2(Vector2(x * grid_size, y * grid_size), Vector2(grid_size, grid_size)), cool_color, true)
