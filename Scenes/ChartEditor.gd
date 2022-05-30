extends Node2D

var song = GameplaySettings.SONG.song

onready var grid = $Grid
onready var selected = $Notes/square
onready var notes = $Notes

onready var dropdowns:Dictionary = {
	"dad": $TabContainer/Song/Opponent/OptionButton,
	"bf": $TabContainer/Song/Player/OptionButton,
	"gf": $TabContainer/Song/GF/OptionButton,
	"stage": $TabContainer/Song/Stage/OptionButton,
	"events": $TabContainer/Events/Label/OptionButton
}

onready var hitsound = $hitsound
onready var iconP2 = $Grid/iconP2
onready var iconP1 = $Grid/iconP1

var selected_x:int = 0
var selected_y:float = 0.0
var note_snap:int = 16
var selected_section:int = 0

var bpm_changes = []
var current_note:Array
var current_note_node:Node2D

var can_interact:bool = true

var playing:bool = false

onready var hitsounds_box = $TabContainer/Charting/Hitsounds
onready var hitsound_volume_slider = $TabContainer/Charting/Label/HSlider

onready var parameters = $TabContainer/Events/Parameters/Them

onready var event_data:Node2D = load("res://Scenes/Events/Nothing.tscn").instance()

onready var charter = self

func _ready():
	if not "events" in song:
		song["events"] = []
		
	var char_list = CoolUtil.list_files_in_directory("res://Scenes/Characters")
	print(char_list)
	for character in char_list:
		if not character.begins_with(".") and character.ends_with(".tscn"):
			character = character.split(".tscn")[0]
			dropdowns["dad"].add_item(character)
			dropdowns["bf"].add_item(character)
			dropdowns["gf"].add_item(character)
			
	dropdowns["dad"].text = song.player2
	dropdowns["dad"].selected = dropdowns["dad"].items.find(song.player2)
	
	dropdowns["bf"].text = song.player1
	dropdowns["bf"].selected = dropdowns["bf"].items.find(song.player1)
	
	var gf_version = "gf"
	match song.song.to_lower():
		"cocoa", "eggnog", "winter horrorland":
			gf_version = "gf-christmas"
		"senpai", "roses", "thorns":
			gf_version = "gf-pixel"
		_:
			gf_version = "gf"
				
	if "player3" in song:
		gf_version = song.player3

	if "gfVersion" in song:
		gf_version = song.gfVersion
		
	if "gf" in song:
		gf_version = song.gf
		
	dropdowns["gf"].text = gf_version
	dropdowns["gf"].selected = dropdowns["bf"].items.find(gf_version)
			
	var stage_list = CoolUtil.list_files_in_directory("res://Scenes/Stages")
	for stage in stage_list:
		if not stage.begins_with(".") and stage.ends_with(".tscn"):
			dropdowns["stage"].add_item(stage.split(".tscn")[0])
			
	var event_list = CoolUtil.list_files_in_directory("res://Scenes/Events")
	for event in event_list:
		if not event.begins_with(".") and event.ends_with(".tscn"):
			dropdowns["events"].add_item(event.split(".tscn")[0])
			
	$TabContainer/Song/SongName/LineEdit.text = song.song
	$TabContainer/Song/Difficulty/LineEdit.text = GameplaySettings.difficulty
	$TabContainer/Song/BPM/LineEdit.text = str(float(song.bpm))
	
	AudioHandler.inst.stream = load(Paths.inst(song.song))
	AudioHandler.voices.stream = load(Paths.voices(song.song))
	
	AudioHandler.inst.pitch_scale = 1
	AudioHandler.inst.volume_db = 0
	
	AudioHandler.voices.pitch_scale = 1
	AudioHandler.voices.volume_db = 0
	
	bpm_changes = Conductor.map_bpm_changes(song)
	Conductor.change_bpm(float(song["bpm"]), bpm_changes)
	
	AudioHandler.stop_music()
	
	var key_count:int = 4
	if "keyCount" in song:
		key_count = song["keyCount"]
		
	_on_LineEdit_text_changed(key_count) # don't ask
	Conductor.song_position = 0
	
func refresh_icons():
	if song.notes[selected_section].mustHitSection:
		iconP2.texture = CoolUtil.load_texture(Paths.icon_path(song.player1))
		iconP1.texture = CoolUtil.load_texture(Paths.icon_path(song.player2))
	else:
		iconP2.texture = CoolUtil.load_texture(Paths.icon_path(song.player2))
		iconP1.texture = CoolUtil.load_texture(Paths.icon_path(song.player1))

func load_section():
	refresh_icons()
		
	for note in notes.get_children():
		if note.name != "square":
			note.free()
	
	"""if not charter.selected_section in charter.song.notes:
		charter.song.notes.append({
			"sectionNotes": [],
			"lengthInSteps": 16,
			"mustHitSection": charter.song.notes[len(charter.song.notes) - 1].mustHitSection
		})"""
		
	if not charter.selected_section in charter.song.notes:
		while not charter.selected_section in range(charter.song.notes.size()):
			charter.song.notes.append({
			"sectionNotes": [],
			"lengthInSteps": 16,
			"mustHitSection": charter.song.notes[len(charter.song.notes) - 1].mustHitSection
		})
			
	if not charter.selected_section in charter.song.events:
		while not charter.selected_section in range(charter.song.events.size()):
			charter.song.events.append([])
	
	for note in charter.song.notes[charter.selected_section].sectionNotes:
		spawn_note(note[1] + 1, time_to_y(note[0] - section_start_time()), time_to_y(note[0] - section_start_time()), note[2])
		
	for event in charter.song.events[charter.selected_section]:
		spawn_event(0, time_to_y(event[0] - section_start_time()), time_to_y(event[0] - section_start_time()))
	
	grid.update()
	
	$TabContainer/Section/MustHitSection.pressed = song.notes[selected_section].mustHitSection

func _process(delta):
	grid.line.rect_position.y = grid.grid_size + time_to_y(Conductor.song_position - section_start_time())
	
	if playing:
		Conductor.song_position += delta * 1000.0
		
		for note in notes.get_children():
			if note.name != "square":
				if y_to_time(note.position.y) <= ((Conductor.song_position - section_start_time()) - AudioServer.get_output_latency()):
					if not "EventNote" in note.name and hitsounds_box.pressed and note.modulate.a == 1 and AudioHandler.inst.playing:
						hitsound.volume_db = hitsound_volume_slider.value
						hitsound.play(0)
					
					note.modulate.a = 0.5
				else:
					note.modulate.a = 1
	
	var key_count:int = 4
	
	if "keyCount" in charter.song:
		key_count = charter.song["keyCount"]
		grid.columns = charter.song["keyCount"] * 2
		grid.update()
		
	grid.position.x = 470 - (((key_count - 4) * grid.grid_size) * 2)
	grid.update()
	
	notes.position.x = grid.position.x
		
	iconP1.position.x = iconP2.position.x + (key_count * grid.grid_size)
	grid.separator2.rect_position.x = iconP1.position.x - (grid.grid_size / 1.7)
	
	if can_interact:
		var prev_selected_x = selected_x
		var prev_selected_y = selected_y
		
		var mouse_pos = get_global_mouse_position()
		mouse_pos.x -= notes.position.x
		mouse_pos.y -= notes.position.y
		
		selected_x = floor(mouse_pos.x / grid.grid_size)
		selected_y = floor(mouse_pos.y / grid.grid_size)
		
		var cool_grid = grid.grid_size / (note_snap / 16.0)
		
		if Input.is_action_pressed("ui_shift"):
			selected.rect_position = Vector2(selected_x * grid.grid_size, mouse_pos.y)
		else:
			selected.rect_position = Vector2(selected_x * grid.grid_size, floor(mouse_pos.y / cool_grid) * cool_grid)
			
		if prev_selected_x != selected_x or prev_selected_y != selected_y:
			update()
		
		if Input.is_action_just_pressed("mouse_left"):
			if selected_x >= 0 and selected_x <= grid.columns:
				if selected_y >= -1 and selected_y < grid.rows - 1:
					if not Input.is_action_pressed("ctrl"):
						var note = add_note(selected_x, selected_y)
						
						if note:
							current_note = note
					else:
						select_note(selected_x, selected_y)
			
		if Input.is_action_just_pressed("ui_left"):
			selected_section -= 1
			if selected_section < 0:
				selected_section = song.notes.size() - 1
			Conductor.song_position = section_start_time()
			load_section()
			
			if playing:
				AudioHandler.inst.play()
				AudioHandler.voices.play()
				
				AudioHandler.inst.seek(Conductor.song_position / 1000.0)
				AudioHandler.voices.seek(Conductor.song_position / 1000.0)
			
		if Input.is_action_just_pressed("ui_right"):
			selected_section += 1
			if selected_section > song.notes.size() - 1:
				selected_section = 0
			Conductor.song_position = section_start_time()
			load_section()
			
			if playing:
				AudioHandler.inst.play()
				AudioHandler.voices.play()
				
				AudioHandler.inst.seek(Conductor.song_position / 1000.0)
				AudioHandler.voices.seek(Conductor.song_position / 1000.0)
			
		if Input.is_action_just_pressed("ui_space"):
			playing = !playing
			if playing:
				AudioHandler.inst.play()
				AudioHandler.voices.play()
				
				AudioHandler.inst.seek(Conductor.song_position / 1000.0)
				AudioHandler.voices.seek(Conductor.song_position / 1000.0)
			else:
				AudioHandler.stop_music()
		elif Input.is_action_just_pressed("ui_accept"):
			SceneHandler.switch_to("PlayState")
			
		if Input.is_action_just_pressed("charting_sustain_up"):
			if current_note:
				if current_note[2] <= 0:
					current_note[2] += Conductor.step_crochet
					current_note_node.charter_sustain.visible = true
				else:
					if Input.is_action_pressed("ui_shift"):
						current_note[2] += Conductor.step_crochet
					else:
						current_note[2] += Conductor.step_crochet / 2
				
				current_note_node.charter_sustain.visible = true
				current_note_node.sustain_length = current_note[2]
				
		if Input.is_action_just_pressed("charting_sustain_down"):
			if current_note:
				current_note[2] -= Conductor.step_crochet / 2
				current_note_node.charter_sustain.visible = true
				
				if current_note[2] < 0:
					current_note_node.charter_sustain.visible = false
					current_note[2] = 0
				
				current_note_node.sustain_length = current_note[2]
			
		if Input.is_action_just_pressed("ui_back"):
			SceneHandler.switch_to("ToolsMenu")
			
		if Conductor.song_position >= section_start_time() + (4 * (1000 * (60 / Conductor.bpm))):
			selected_section += 1
			if selected_section > song.notes.size() - 1:
				song.notes.append({
					"lengthInSteps": 16,
					"bpm": song.bpm,
					"changeBPM": false,
					"mustHitSection": song.notes[selected_section - 1].mustHitSection,
					"sectionNotes": [],
					"altAnim": false
				})
			load_section()
			
		if Conductor.song_position / 1000.0 >= AudioHandler.inst.stream.get_length():
			Conductor.song_position = 0.0
			selected_section = 0
			load_section()
		
func y_to_time(y):
	return range_lerp(y + grid.grid_size, position.y, position.y + (grid.rows * grid.grid_size), 0, 16 * Conductor.step_crochet)

func time_to_y(time):
	return range_lerp(time - Conductor.step_crochet, 0, 16 * Conductor.step_crochet, position.y, position.y + (grid.rows * grid.grid_size))

func section_start_time(section = null):
	if section == null:
		section = charter.selected_section
	
	var coolPos:float = 0.0
	
	var good_bpm = Conductor.bpm
	
	for i in section:
		if "changeBPM" in charter.song.notes[i]:
			if charter.song.notes[i]["changeBPM"] == true:
				good_bpm = charter.song.notes[i]["bpm"]
		
		coolPos += 4 * (1000 * (60 / good_bpm))
	
	return coolPos
	
func clone_section(section:int = 0):
	if song.notes[section]:
		for note in song.notes[section].sectionNotes:
			var data = []
			
			for i in len(note):
				data.append(note[i])
			
			data[0] -= section_start_time(section)
			data[0] += section_start_time()
			
			song.notes[selected_section].sectionNotes.append(data)
		
		load_section()
		
var kill_me = 0
	
func select_note(x, y):
	var mouse_pos = get_global_mouse_position()
	mouse_pos.x -= notes.position.x
	mouse_pos.y -= notes.position.y
	
	for note in notes.get_children():
		if note.name != "square":
			if selected_x * grid.grid_size == note.position.x:
				if mouse_pos.y >= note.position.y and mouse_pos.y <= note.position.y + grid.grid_size:
					for note_object in charter.song.notes[charter.selected_section].sectionNotes:
						if note_object[1] == int(x - 1):
							if int(note_object[0]) == int(y_to_time(note.position.y) + section_start_time()):
								current_note = note_object
								current_note_node = note
					#return
					
	# selecting events!!
	for note in notes.get_children():
		if note.name != "square":
			if selected_x * grid.grid_size == note.position.x:
				if mouse_pos.y >= note.position.y and mouse_pos.y <= note.position.y + grid.grid_size:
					var index:int = 0
					for note_object in charter.song.events[charter.selected_section]:
						if int(note_object[0]) == int(y_to_time(note.position.y) + section_start_time()):
							current_note = note_object
							current_note_node = note
							
							kill_me = index
							print(kill_me)
							
							if "EventNote" in current_note_node.name:
								event_data = note_object[1]
								
							_on_Event_item_selected(0)
								
							print("PARAMS: " + str(event_data.params))
							
						index += 1
					#return

func add_note(x, y):
	var mouse_pos = get_global_mouse_position()
	mouse_pos.x -= notes.position.x
	mouse_pos.y -= notes.position.y
	
	for note in notes.get_children():
		if note.name != "square":
			if selected_x * grid.grid_size == note.position.x:
				if mouse_pos.y >= note.position.y and mouse_pos.y <= note.position.y + grid.grid_size:
					for note_object in charter.song.notes[charter.selected_section].sectionNotes:
						if note_object[1] == int(x - 1):
							if int(note_object[0]) == int(y_to_time(note.position.y) + section_start_time()):
								charter.song.notes[charter.selected_section].sectionNotes.erase(note_object)
					
					note.queue_free()
					return
					
	var note
	
	if int(x - 1) <= -1:
		note = spawn_event(x, y, null, 0)
		
		var strum_time = (y_to_time(selected.rect_position.y) + section_start_time())
		
		var data = [strum_time, event_data]
		charter.song.events[charter.selected_section].append(data)
		
		current_note = data
		current_note_node = note
		
		_on_Event_item_selected(0)
	else:
		note = spawn_note(x, y, null, 0)
		
		#note.modulate.a = 0.5
		
		var strum_time = (y_to_time(selected.rect_position.y) + section_start_time())
		var note_data = int(x - 1)
		var note_length = 0.0
		
		var data = [strum_time, note_data, note_length]
		charter.song.notes[charter.selected_section].sectionNotes.append(data)
		
		current_note = data
		current_note_node = note
		
		return charter.song.notes[charter.selected_section].sectionNotes[len(charter.song.notes[charter.selected_section].sectionNotes) - 1]

var event_note:Node2D = load("res://Scenes/ChartEditor/EventNote.tscn").instance()

func spawn_event(x, y, custom_y = null, sustain_length:float = 0.0):
	if custom_y == null:
		custom_y = selected.rect_position.y
	
	var mouse_pos = get_global_mouse_position()
	mouse_pos.x -= position.x
	mouse_pos.y -= position.y
	
	var new_note = event_note.duplicate()
	new_note.position = Vector2(x * grid.grid_size, custom_y)
	notes.add_child(new_note)
	
	var anim_spr = new_note.get_node("spr")
	anim_spr.offset.x += grid.grid_size * 9
	anim_spr.offset.y += grid.grid_size * 9
	new_note.scale.x = grid.grid_size / anim_spr.texture.get_height()
	new_note.scale.y = grid.grid_size / anim_spr.texture.get_height()

func spawn_note(x, y, custom_y = null, sustain_length:float = 0.0):
	if custom_y == null:
		custom_y = selected.rect_position.y
	
	var mouse_pos = get_global_mouse_position()
	mouse_pos.x -= position.x
	mouse_pos.y -= position.y
	
	var new_note = GameplaySettings.note_types["Default"].duplicate()
	new_note.position = Vector2(x * grid.grid_size, custom_y)
	new_note.charter_note = true
	new_note.sustain_length = sustain_length
	notes.add_child(new_note)
	
	new_note.charter_sustain.rect_position += Vector2(grid.grid_size * 2, grid.grid_size * 2)
	
	var key_count:int = 4
	
	if "keyCount" in charter.song:
		key_count = int(charter.song["keyCount"])
	
	var anim_spr = new_note.spr
	anim_spr.offset.x += grid.grid_size * 2
	anim_spr.offset.y += grid.grid_size * 2
	anim_spr.play(NoteFunctions.dir_to_str(int(x - 1) % key_count, key_count))
	new_note.scale.x = grid.grid_size / anim_spr.frames.get_frame(anim_spr.animation, anim_spr.frame).get_height()
	new_note.scale.y = grid.grid_size / anim_spr.frames.get_frame(anim_spr.animation, anim_spr.frame).get_height()
	
	if sustain_length > 0:
		var sustain = new_note.charter_sustain
		sustain.visible = true
		sustain.rect_size.y = floor(range_lerp(sustain_length, 0, Conductor.step_crochet * 16, 0, grid.rows * grid.grid_size)) / new_note.scale.y
	
	return new_note

func _on_LineEdit_focus_entered():
	can_interact = false

func _on_LineEdit_focus_exited():
	can_interact = true

func _on_LineEdit_text_changed(new_text):
	var value = float(new_text)
	if value < 1:
		value = 1
	if value > 9:
		value = 9
		
	GameplaySettings.key_count = value
	song["keyCount"] = value
	grid.columns = value * 2
	grid.update()
	
	grid.line.rect_size.x = (1 + (value * 2)) * grid.grid_size
	
	load_section()

func _on_ReloadAudio_pressed():
	var fuck = $TabContainer/Song/SongName/LineEdit.text
	playing = false
	AudioHandler.stop_music()
	AudioHandler.inst.stream = load(Paths.inst(fuck))
	AudioHandler.voices.stream = load(Paths.voices(fuck))
	
func _on_ReloadJSON_pressed():
	var fuck = $TabContainer/Song/SongName/LineEdit.text
	playing = false
	AudioHandler.stop_music()
	AudioHandler.inst.stream = load(Paths.inst(fuck))
	AudioHandler.voices.stream = load(Paths.voices(fuck))
	
	Conductor.song_position = 0.0
	GameplaySettings.SONG = CoolUtil.get_json(Paths.song_json(fuck, $TabContainer/Song/Difficulty/LineEdit.text))
	SceneHandler.switch_to("ChartEditor")

func _on_BPM_changed(new_text):
	song.bpm = float(new_text)
	Conductor.bpm = song.bpm
	load_section()

func _on_CopyLastSection_pressed():
	clone_section(selected_section - int($TabContainer/Section/NumericStepper.value))

func _on_YesDeleteSection_pressed():
	can_interact = true
	$Warnings/ClearCurrentSection.visible = false
	song.notes[selected_section].sectionNotes.clear()
	load_section()
	
func _on_NoDeleteSection_pressed():
	can_interact = true
	$Warnings/ClearCurrentSection.visible = false

func _on_CopySection_pressed():
	clone_section(int($TabContainer/Section/NumericStepper2.value))

func _on_ClearCurrent_pressed():
	can_interact = false
	$Warnings/ClearCurrentSection.visible = true

func _on_SwapSection_pressed():
	for note in song.notes[selected_section].sectionNotes:
		note[1] = int(note[1] + GameplaySettings.key_count) % (GameplaySettings.key_count * 2)
		
	load_section()

func _on_NoDeleteNotes_pressed():
	can_interact = true
	$Warnings/ClearAllNotes.visible = false

func _on_YesDeleteNotes_pressed():
	can_interact = true
	$Warnings/ClearAllNotes.visible = false
	
	for section in song.notes:
		section.sectionNotes.clear()
		
	load_section()

func _on_NoDeleteEvents_pressed():
	can_interact = true
	$Warnings/ClearAllEvents.visible = false

func _on_YesDeleteEvents_pressed():
	can_interact = true
	$Warnings/ClearAllEvents.visible = false
	
	if "events" in song:
		song.events.clear()
		
	load_section()

func _on_ClearAllNotes_pressed():
	can_interact = false
	$Warnings/ClearAllNotes.visible = true

func _on_ClearAllEvents_pressed():
	can_interact = false
	$Warnings/ClearAllEvents.visible = true

func _on_MustHitSection_pressed():
	song.notes[selected_section].mustHitSection = $TabContainer/Section/MustHitSection.pressed
	refresh_icons()
	
var parameter_shit:Node2D = load("res://Scenes/ChartEditor/ParameterShit.tscn").instance()

func _on_Event_item_selected(index):
	var path = "res://Scenes/Events/" + dropdowns["events"].text + ".tscn"
	event_data = load(path).instance()
	
	for param in event_data.parameters:
		event_data.params[param] = ""
		
	print(event_data.params.keys())
	
	for param in parameters.get_children():
		parameters.remove_child(param)
		param.queue_free()
		
	var i:int = 0
	for param in event_data.params.keys():
		var new_shit:Node2D = parameter_shit.duplicate()
		new_shit.position.y = i * 50
		new_shit.event_data = event_data
		parameters.add_child(new_shit)
		
		new_shit.label.text = param
		i += 1

func _on_SeeEventDescription_pressed():
	var contents = {
		"box": $Warnings/EventDescription,
		"title": $Warnings/EventDescription/Label,
		"desc": $Warnings/EventDescription/Label2
	}
	
	can_interact = false
	contents["title"].text = event_data.name
	contents["desc"].text = event_data.description
	
	contents["box"].visible = true

func _on_Exit_pressed():
	can_interact = true
	$Warnings/EventDescription.visible = false

func _on_DadDropdown_item_selected(index):
	song.player2 = $TabContainer/Song/Opponent/OptionButton.text

func _on_PlayerDropdown_item_selected(index):
	song.player1 = $TabContainer/Song/Player/OptionButton.text

func _on_GFDropDown_item_selected(index):
	song.gf = $TabContainer/Song/GF/OptionButton.text

func _on_StageDropdown_item_selected(index):
	song.stage = $TabContainer/Song/Stage/OptionButton.text
