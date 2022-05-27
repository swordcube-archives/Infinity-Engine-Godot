extends Node2D

onready var enemy_strums = $Opponent
onready var strums = $Player
onready var notes = $MainSection
onready var notes2 = $FardSection

onready var iconP2 = $IconP2
onready var iconP1 = $IconP1

onready var info = $Label

var cur_section:int = 0

var SONG = GameplaySettings.SONG.song

var playing:bool = false

var scroll_speed:float = 1

func _ready():
	Conductor.change_bpm(SONG.bpm)
	Conductor.connect("beat_hit", self, "beat_hit")
	Conductor.song_position = Conductor.crochet * -0.02
	load_notes()
	
	AudioHandler.inst.stream = load(Paths.inst(SONG.song))
	AudioHandler.voices.stream = load(Paths.voices(SONG.song))
	
func load_notes():
	if SONG.notes[cur_section].mustHitSection:
		iconP2.texture = CoolUtil.load_texture(Paths.icon_path(SONG.player1))
		iconP1.texture = CoolUtil.load_texture(Paths.icon_path(SONG.player2))
	else:
		iconP2.texture = CoolUtil.load_texture(Paths.icon_path(SONG.player2))
		iconP1.texture = CoolUtil.load_texture(Paths.icon_path(SONG.player1))
		
	for note in notes.get_children():
		notes.remove_child(note)
		note.queue_free()
		
	for note in notes2.get_children():
		notes2.remove_child(note)
		note.queue_free()
		
	for note in SONG.notes[cur_section].sectionNotes:
		var new_note = GameplaySettings.note_types["Default"].duplicate()
		new_note.note_data = int(note[1]) % GameplaySettings.key_count
		new_note.direction = strums.get_child(new_note.note_data).direction
		new_note.strum_time = note[0]
		new_note.scale = Vector2(0.5, 0.5)
		
		new_note.must_press = false
		var strum = enemy_strums.get_child(int(note[1]) % GameplaySettings.key_count)
		if int(note[1]) >= GameplaySettings.key_count:# or SONG.notes[cur_section].mustHitSection:
			new_note.must_press = true 
			strum = strums.get_child(int(note[1]) % GameplaySettings.key_count)
			
		new_note.global_position.x = strum.global_position.x
		new_note.position.y = (-0.45 * (0 - note[0])) * scroll_speed
		notes.add_child(new_note)
		if note[2] > 0:
			new_note.og_sustain_length = note[2]
			new_note.charter_sustain.visible = true
			new_note.charter_sustain.rect_size.y = note[2]
		
	if range(SONG.notes.size()).has(cur_section + 1):
		for note in SONG.notes[cur_section + 1].sectionNotes:
			var new_note = GameplaySettings.note_types["Default"].duplicate()
			new_note.note_data = int(note[1]) % GameplaySettings.key_count
			new_note.direction = strums.get_child(new_note.note_data).direction
			new_note.strum_time = note[0]
			new_note.scale = Vector2(0.5, 0.5)
			
			new_note.must_press = false
			var strum = enemy_strums.get_child(int(note[1]) % GameplaySettings.key_count)
			if int(note[1]) >= GameplaySettings.key_count:# or SONG.notes[cur_section + 1].mustHitSection:
				new_note.must_press = true 
				strum = strums.get_child(int(note[1]) % GameplaySettings.key_count)
				
			new_note.global_position.x = strum.global_position.x
			new_note.position.y = (-0.45 * (0 - note[0])) * scroll_speed
			notes2.add_child(new_note)
			if note[2] > 0:
				new_note.og_sustain_length = note[2]
				new_note.charter_sustain.visible = true
				new_note.charter_sustain.rect_size.y = note[2]
		
func section_start_time(section = null):
	if section == null:
		section = cur_section
	
	var coolPos:float = 0.0
	
	var good_bpm = SONG["bpm"]
	
	for i in section:
		if "changeBPM" in SONG.notes[i]:
			if SONG.notes[i]["changeBPM"] == true and SONG.notes[i]["bpm"] > 0:
				good_bpm = SONG.notes[i]["bpm"]
		
		coolPos += 4.0 * (1000.0 * (60.0 / good_bpm))
	
	return coolPos
	
func _physics_process(delta):
	iconP2.scale = lerp(iconP2.scale, Vector2(0.5, 0.5), 0.2)
	iconP1.scale = lerp(iconP1.scale, Vector2(0.5, 0.5), 0.2)
		
func _process(delta):	
	for num in GameplaySettings.key_count:
		if Input.is_action_just_pressed("gameplay_" + str(num)):
			var note = [Conductor.song_position, num, 0.0]
			
			var new_note = GameplaySettings.note_types["Default"].duplicate()
			new_note.note_data = int(note[1]) % GameplaySettings.key_count
			new_note.direction = strums.get_child(new_note.note_data).direction
			new_note.strum_time = note[0]
			new_note.scale = Vector2(0.5, 0.5)
			
			new_note.must_press = !$TabContainer/Charting/EnemySide.pressed				
			var strum = enemy_strums.get_child(int(note[1]) % GameplaySettings.key_count)
			if SONG.notes[cur_section].mustHitSection:
				new_note.must_press = !new_note.must_press
				
			if new_note.must_press:
				note[1] = (note[1] + GameplaySettings.key_count) % (GameplaySettings.key_count * 2)
				strum = strums.get_child(int(note[1]) % GameplaySettings.key_count)
				
			new_note.global_position.x = strum.global_position.x
			new_note.position.y = (-0.45 * (0 - note[0])) * scroll_speed
			notes.add_child(new_note)
			
			SONG.notes[cur_section].sectionNotes.append(note)
			
	if Input.is_action_just_pressed("ui_space"):
		playing = !playing
		if Conductor.song_position == Conductor.crochet * -0.02:
			Conductor.song_position = 0.0
			
		if playing:
			AudioHandler.play_inst(SONG.song)
			AudioHandler.play_voices(SONG.song)
			
			AudioHandler.inst.seek(Conductor.song_position / 1000.0)
			AudioHandler.voices.seek(Conductor.song_position / 1000.0)
		else:
			AudioHandler.stop_music()
	elif Input.is_action_just_pressed("ui_accept"):
		SceneHandler.switch_to("PlayState")
		
	if Input.is_action_just_pressed("ui_left"):
		cur_section -= 1
		if cur_section < 0:
			cur_section = SONG.notes.size() - 1
			
		load_notes()
		Conductor.song_position = section_start_time()
		
		if playing:
			AudioHandler.play_inst(SONG.song)
			AudioHandler.play_voices(SONG.song)
			
			AudioHandler.inst.seek(Conductor.song_position / 1000.0)
			AudioHandler.voices.seek(Conductor.song_position / 1000.0)
		
	if Input.is_action_just_pressed("ui_right"):
		cur_section += 1
		if cur_section > SONG.notes.size() - 1:
			cur_section = 0
			
		load_notes()
		Conductor.song_position = section_start_time()
		
		if playing:
			AudioHandler.play_inst(SONG.song)
			AudioHandler.play_voices(SONG.song)
			
			AudioHandler.inst.seek(Conductor.song_position / 1000.0)
			AudioHandler.voices.seek(Conductor.song_position / 1000.0)
		
	if playing:
		Conductor.song_position += delta * 1000.0
		
	if Conductor.song_position / 1000.0 >= AudioHandler.inst.stream.get_length():
		Conductor.song_position = 0
		cur_section = 0
		load_notes()
		
	if Conductor.song_position >= section_start_time() + (4 * (1000 * (60 / Conductor.bpm))):
		cur_section += 1
		load_notes()
		
	for i in strums.get_child_count():
		if enemy_strums.get_child(i).anim_finished:
			enemy_strums.get_child(i).play_anim("")
			
		if strums.get_child(i).anim_finished:
			strums.get_child(i).play_anim("")
		
	for note in notes.get_children():
		if Conductor.song_position >= note.strum_time:
			if not note.being_pressed:
				note.being_pressed = true
				if note.must_press:
					strums.get_child(note.note_data).play_anim("confirm")
				else:
					enemy_strums.get_child(note.note_data).play_anim("confirm")
		
	notes.position.y = strums.position.y + (-0.45 * (Conductor.song_position)) * scroll_speed
	notes2.position.y = strums.position.y + (-0.45 * (Conductor.song_position)) * scroll_speed
	
	info.text = "Current Section: " + str(int(Conductor.cur_step / 16))
	info.text += "\nSong Position: " + CoolUtil.format_time(Conductor.song_position / 1000.0) + "/" + CoolUtil.format_time(AudioHandler.inst.stream.get_length())
	info.text += "\nCur Beat: " + str(Conductor.cur_beat)
	info.text += "\nCur Step: " + str(Conductor.cur_step)

func beat_hit():
	iconP2.scale += Vector2(0.2, 0.2)
	iconP1.scale += Vector2(0.2, 0.2)
