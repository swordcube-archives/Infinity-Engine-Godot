extends Node2D

var note_type = "Default"
var stopped_init_audio = false

var bpm_changes = []

var curSection = 0

var playing = false

var characters = []

var can_interact = true

var curEvent = 0

var note_types = []

func _ready():
	Events.init_event_list()
	
	for event in Events.event_list:
		$Tabs/Events/Event/EventDropdown.add_item(event[0])
	
	var fuck = Util.list_files_in_directory("res://Scenes/Notes/")
	for file in fuck:
		if not "." in file:
			note_types.append(file)
			$Tabs/Notes/NoteType/NoteTypeDropdown.add_item(file)
		
	if not "keyCount" in Gameplay.SONG.song:
		Gameplay.SONG.song.keyCount = 4
		
	reload_event_description(0)
	
	$Tabs.current_tab = 4
	
	$Tabs/Song/Song/SongInput.text = Gameplay.SONG.song.song
	$Tabs/Song/Song/CheckBox.pressed = Gameplay.SONG.song["needsVoices"] == true
	$Tabs/Song/Song/ScrollSpeed/SpeedInput.text = str(Gameplay.SONG.song.speed)
	$Tabs/Song/Song/BPM/BPMInput.text = str(Gameplay.SONG.song.bpm)
	$Tabs/Song/Difficulty/DiffInput.text = Gameplay.difficulty
	$Tabs/Song/KeyCount/KeyInput.text = str(Gameplay.SONG.song.keyCount)
	
	var char_list = Util.list_files_in_directory("res://Characters")
	
	for character in char_list:
		if not "." in character:
			characters.append(character)
			$Tabs/Song/Characters/Opponent.add_item(character)
			$Tabs/Song/Characters/GF.add_item(character)
			$Tabs/Song/Characters/BF.add_item(character)
			
	var stage_list = Util.list_files_in_directory("res://Stages")
	
	for stage in stage_list:
		if not "." in stage:
			$Tabs/Song/Characters/Stage.add_item(stage)
	
	$Tabs/Song/Characters/Opponent.text = Gameplay.SONG.song.player2
	
	var stage = "stage"
	var gf_version = "gf"
	match(Gameplay.SONG.song.song.to_lower()):
		"spookeez", "south", "monster":
			stage = "spooky"
		"pico", "philly nice", "blammed":
			stage = "philly"
		"satin panties", "high", "m.i.l.f":
			stage = "limo"
		"cocoa", "eggnog":
			stage = "mall"
			gf_version = "gf-christmas"
		"winter-horrorland":
			stage = "mallEvil"
			gf_version = "gf-christmas"
		"senpai":
			stage = "school"
			gf_version = "gf-pixel"
		"roses":
			stage = "schoolAngry"
			gf_version = "gf-pixel"
		"thorns":
			stage = "schoolEvil"
			gf_version = "gf-pixel"
		_:
			var real = "gf"
			
			if not "gfVersion" in Gameplay.SONG.song:
				real = "gf"
			else:
				real = Gameplay.SONG.song.gfVersion
				
			if not "gf" in Gameplay.SONG.song:
				real = "gf"
			else:
				real = Gameplay.SONG.song.gf
				
			if not "player3" in Gameplay.SONG.song:
				real = "gf"
			else:
				real = Gameplay.SONG.song.player3
				
			# gfVersion / gf = psych i think
			# player3 = idfk, probably used in some other engines
				
			gf_version = real
	
	$Tabs/Song/Characters/GF.text = gf_version
	$Tabs/Song/Characters/BF.text = Gameplay.SONG.song.player1
	
	$Tabs/Song/Characters/Stage.text = stage
	
	AudioHandler.get_node("Inst").stream = load(Paths.inst(Gameplay.SONG.song.song))
	AudioHandler.get_node("Voices").stream = load(Paths.voices(Gameplay.SONG.song.song))
	
	AudioHandler.get_node("Inst").pitch_scale = 1
	AudioHandler.get_node("Voices").pitch_scale = 1
	
	AudioHandler.get_node("Inst").seek(AudioHandler.get_node("Inst").stream.get_length())
	
	if AudioHandler.get_node("Voices").stream != null:
		AudioHandler.get_node("Voices").seek(AudioHandler.get_node("Voices").stream.get_length())
	
	Conductor.songPosition = 0
	
	for section in Gameplay.SONG.song["notes"]:
		if "changeBPM" in section:
			if section["changeBPM"]:
				bpm_changes.append([$Grid.section_start_time(Gameplay.SONG.song["notes"].find(section)), float(section["bpm"])])
	
	Conductor.change_bpm(float(Gameplay.SONG.song["bpm"]), bpm_changes)
	
	# 0 = Strum Time
	# 1 = Note Data
	# 2 = Sustain Length
	
	change_section(0)
	
	#print(Gameplay.SONG.song.notes[curSection].mustHitSection)
	
var selected_event = 0

func _process(delta):
	var inst_length = 0
	
	if AudioHandler.get_node("Inst").stream != null:
		inst_length = AudioHandler.get_node("Inst").stream.get_length()
	else:
		inst_length = 0
		
	$Stats.text = "Song Position: " + Util.format_time(Conductor.songPosition / 1000.0) + " / " + Util.format_time(inst_length)
	$Stats.text += "\nCurrent Beat: " + str(Conductor.curBeat)
	$Stats.text += "\nCurrent Step: " + str(Conductor.curStep)
	$Stats.text += "\nCurrent Section: " + str(curSection)
	
	$IconP2.position.x = ($Grid.position.x - ($Grid.grid_size * (Gameplay.SONG.song.keyCount - 2))) + (Gameplay.SONG.song.keyCount * $Grid.grid_size)
	$IconP1.position.x = $IconP2.position.x + (Gameplay.SONG.song.keyCount * $Grid.grid_size)
	
	Gameplay.SONG.song.events = $Grid.events
	
	if $Grid.selected_event != null:
		$Tabs/Events/MergedEvents.text = "Selected Event (" + str(selected_event) + "/" + str(len($Grid.selected_event[1]) - 1) + ")"
	else:
		$Tabs/Events/MergedEvents.text = "Selected Event (" + str(selected_event) + "/0)"
		
	if can_interact:	
		if Input.is_action_just_pressed("ui_back"):
			playing = false
			AudioHandler.stop_inst()
			AudioHandler.stop_voices()
			SceneManager.switch_scene("MainMenu")
			
		if Input.is_action_just_pressed("ui_left"):
			change_section(-1)
			
		if Input.is_action_just_pressed("ui_right"):
			change_section(1)
			
		if $Grid.selected_note != null:
			if Input.is_action_just_pressed("charting_sustain_up"):
				if $Grid.selected_note[2] <= 0:
					$Grid.selected_note[2] += Conductor.timeBetweenSteps
				else:
					if Input.is_action_pressed("ui_shift"):
						$Grid.selected_note[2] += Conductor.timeBetweenSteps
					else:
						$Grid.selected_note[2] += Conductor.timeBetweenSteps / 2
						
				$Grid.selected_note_object.sustainLength = $Grid.selected_note[2]
				$Grid.selected_note_object.line.visible = true
					
			if Input.is_action_just_pressed("charting_sustain_down"):
				if Input.is_action_pressed("ui_shift"):
					$Grid.selected_note[2] -= Conductor.timeBetweenSteps
				else:
					$Grid.selected_note[2] -= Conductor.timeBetweenSteps / 2
				
				if $Grid.selected_note[2] <= 0:
					$Grid.selected_note[2] = 0
					$Grid.selected_note_object.line.visible = false
			
				$Grid.selected_note_object.sustainLength = $Grid.selected_note[2]
			
		if Input.is_action_just_pressed("space"):
			playing = not playing
			
			if playing:
				AudioHandler.play_inst(Gameplay.SONG.song.song)
				AudioHandler.get_node("Inst").seek(Conductor.songPosition / 1000.0)
				
				if Gameplay.SONG.song["needsVoices"]:
					AudioHandler.play_voices(Gameplay.SONG.song.song)
					AudioHandler.get_node("Voices").seek(Conductor.songPosition / 1000.0)
			else:
				AudioHandler.stop_inst()
				AudioHandler.stop_voices()
				
		if Input.is_action_just_pressed("ui_confirm"):
			playing = false
			AudioHandler.stop_inst()
			AudioHandler.stop_voices()
			SceneManager.switch_scene("PlayState")
			
	if playing:
		Conductor.songPosition += delta * 1000
		
		if Conductor.songPosition >= $Grid.section_start_time() + (4 * (1000 * (60 / Conductor.bpm))):
			change_section(1)
			
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				Conductor.songPosition -= 25
				
				if Conductor.songPosition < $Grid.section_start_time():
					curSection -= 1
					
					if Conductor.songPosition < 0:
						Conductor.songPosition = 0
					
					if curSection < 0:
						curSection = 0
					
					$Grid.load_section(curSection)
					update()
			
			if event.button_index == BUTTON_WHEEL_DOWN:
				Conductor.songPosition += 25
				
				if Conductor.songPosition > $Grid.section_start_time() + (4 * (1000 * (60 / Conductor.bpm))):
					change_section(1)
					update()
		
func change_section(amount):
	curSection += amount
	if curSection < 0:
		curSection = len(Gameplay.SONG.song.notes) - 1
	if curSection > len(Gameplay.SONG.song.notes) - 1:
		curSection = 0
		
	Conductor.songPosition = $Grid.section_start_time()
	
	if playing:
		AudioHandler.get_node("Inst").play(Conductor.songPosition / 1000)
		AudioHandler.get_node("Voices").play(Conductor.songPosition / 1000)			
	
	refresh_icons()
		
	$Grid.load_section(curSection)
	
func clear_notes():
	for section in Gameplay.SONG.song.notes:
		section["sectionNotes"].clear()
		
func clear_events():
	$Grid.events.clear()

func refresh_icons():
	if Gameplay.SONG.song.notes[curSection].mustHitSection:
		$IconP2.texture = Paths.image("Icons/" + Gameplay.SONG.song.player1)
		$IconP1.texture = Paths.image("Icons/" + Gameplay.SONG.song.player2)
	else:
		$IconP2.texture = Paths.image("Icons/" + Gameplay.SONG.song.player2)
		$IconP1.texture = Paths.image("Icons/" + Gameplay.SONG.song.player1)

func _on_Opponent_item_selected(index):
	Gameplay.SONG.song.player2 = $Tabs/Song/Characters/Opponent.text
	$Tabs/Song/Characters/Opponent.release_focus()
	refresh_icons()

func _on_GF_item_selected(index):
	Gameplay.SONG.song.gfVersion = $Tabs/Song/Characters/GF.text
	$Tabs/Song/Characters/GF.release_focus()
	refresh_icons()

func _on_BF_item_selected(index):
	Gameplay.SONG.song.player1 = $Tabs/Song/Characters/BF.text
	$Tabs/Song/Characters/BF.release_focus()
	refresh_icons()

func _on_SongInput_focus_entered():
	can_interact = false

func _on_SongInput_focus_exited():
	can_interact = true

func _on_LoadAudio_pressed():
	playing = false
	
	AudioHandler.stop_inst()
	AudioHandler.stop_voices()
	
	Gameplay.SONG.song.song = $Tabs/Song/Song/SongInput.text
	
	AudioHandler.get_node("Inst").stream = load(Paths.inst(Gameplay.SONG.song.song))
	AudioHandler.get_node("Voices").stream = load(Paths.voices(Gameplay.SONG.song.song))
	
	$Tabs/Song/Song/LoadAudio.release_focus()

func _on_CheckBox_pressed():
	Gameplay.SONG.song["needsVoices"] = $Tabs/Song/Song/CheckBox.pressed
	
	$Tabs/Song/Song/CheckBox.release_focus()

func _on_SpeedInput_text_changed():
	Gameplay.SONG.song.speed = float($Tabs/Song/Song/ScrollSpeed/SpeedInput.text)

func _on_BPMInput_text_changed():
	Gameplay.SONG.song.bpm = float($Tabs/Song/Song/BPM/BPMInput.text)
	if Gameplay.SONG.song.bpm <= 0:
		Gameplay.SONG.song.bpm = 1 # we can't divide by 0 or else we die!!
		
	Conductor.change_bpm(Gameplay.SONG.song.bpm)

func _on_SaveChart_pressed():
	print("DOESN'T WORK YET")

func _on_ReloadJSON_pressed():
	var json = JsonUtil.get_json("res://Assets/Songs/" + str($Tabs/Song/Song/SongInput.text) + "/" + str($Tabs/Song/Difficulty/DiffInput.text).to_lower())
	
	if json != null:
		Gameplay.SONG = json
		
		if not "keyCount" in Gameplay.SONG.song:
			Gameplay.SONG.song.keyCount = 4
		
		Gameplay.difficulty = str($Tabs/Song/Difficulty/DiffInput.text).to_lower()
		SceneManager.switch_scene("ChartEditor")
	else:
		AudioHandler.play_audio("cancelMenu")

func _on_Stage_item_selected(index):
	Gameplay.SONG.song.stage = $Tabs/Song/Characters/Stage.text

func _on_ClearNotes_pressed():
	clear_notes()
	$Grid.load_section(curSection)

func _on_ClearEvents_pressed():
	clear_events()
	$Grid.load_section(curSection)

func _on_SaveEvents_pressed():
	pass # Replace with function body.

func _on_EventDropdown_item_selected(index):
	reload_event_description(index)
	
func reload_event_description(index):
	var description = ""
	
	curEvent = index
		
	for line in Events.event_list[index][1]:
		description += str(line) + "\n"
		
	if $Grid.selected_event != null:
		$Grid.selected_event[1][selected_event][0] = Events.event_list[index][0]
		
	$Tabs/Events/Description.text = description

func _on_Value1Input_focus_entered():
	can_interact = false

func _on_Value1Input_focus_exited():
	can_interact = true

func _on_Value2Input_focus_entered():
	can_interact = false

func _on_Value2Input_focus_exited():
	can_interact = true

func _on_Value1Input_text_changed():
	if $Grid.selected_event != null:
		$Grid.selected_event[1][selected_event][1] = $Tabs/Events/Value1/Value1Input.text
		#print($Grid.selected_event[1][0][1])

func _on_Value2Input_text_changed():
	if $Grid.selected_event != null:
		$Grid.selected_event[1][selected_event][2] = $Tabs/Events/Value2/Value2Input.text
		#print($Grid.selected_event[1][0][2])
		
func change_event(amount):
	var length = 0
	
	if $Grid.selected_event != null:
		length = len($Grid.selected_event[1])
		
	selected_event += amount
	if selected_event < 0:
		selected_event = length - 1
	if selected_event > length - 1:
		selected_event = 0
		
	$Tabs/Events/Event/EventDropdown.text = $Grid.selected_event[1][selected_event][0]
	var index = 0
	for event in Events.event_list:
		if event[0] == $Grid.selected_event[1][selected_event][0]:
			reload_event_description(index)
			$Tabs/Events/Value1/Value1Input.text = $Grid.selected_event[1][selected_event][1]
			$Tabs/Events/Value2/Value2Input.text = $Grid.selected_event[1][selected_event][2]
			
		index += 1
	
func _on_MergedEventsLeft_pressed():
	change_event(-1)
	
func _on_MergedEventsRight_pressed():
	change_event(1)

func _on_MergedEventsPlus_pressed():
	if $Grid.selected_event != null:
		$Grid.selected_event[1].append(["???", "", ""])
		
		selected_event = len($Grid.selected_event[1]) - 1
		$Tabs/Events/Event/EventDropdown.text = $Grid.selected_event[1][selected_event][0]
		
		change_event(0)

func _on_KeyInput_text_changed():
	Gameplay.SONG.song.keyCount = int($Tabs/Song/KeyCount/KeyInput.text)
	
	if Gameplay.SONG.song.keyCount <= 1:
		Gameplay.SONG.song.keyCount = 1
		
	# 0 keys would basically just be no chart
	
	if Gameplay.SONG.song.keyCount > 9:
		Gameplay.SONG.song.keyCount = 9
		
	# if you want even more keys than this, i'll add it when i feel like it
	
	$Grid.load_section(curSection)

func _on_NoteTypeDropdown_item_selected(index):
	if $Grid.selected_note != null: 
		$Grid.selected_note[3] = $Tabs/Notes/NoteType/NoteTypeDropdown.text
		$Grid.load_section(curSection)

func _on_CameraP1_pressed():
	Gameplay.SONG.song.notes[curSection].mustHitSection = $Tabs/Section/CameraP1.pressed
	$Tabs/Section/CameraP1.release_focus()
	refresh_icons()
