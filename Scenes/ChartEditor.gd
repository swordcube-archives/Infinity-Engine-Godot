extends Node2D

var note_type = "Default"
var stopped_init_audio = false

var bpm_changes = []

var curSection = 0

var playing = false

var characters = []

var can_interact = true

func _ready():
	$Tabs/Song/Song/SongInput.text = Gameplay.SONG.song.song
	$Tabs/Song/Song/CheckBox.pressed = Gameplay.SONG.song["needsVoices"] == true
	$Tabs/Song/Song/ScrollSpeed/SpeedInput.text = str(Gameplay.SONG.song.speed)
	$Tabs/Song/Song/BPM/BPMInput.text = str(Gameplay.SONG.song.bpm)
	
	var char_list = Util.list_files_in_directory("res://Characters")
	
	for character in char_list:
		if not "." in character:
			characters.append(character)
			$Tabs/Song/Characters/Opponent.add_item(character)
			$Tabs/Song/Characters/GF.add_item(character)
			$Tabs/Song/Characters/BF.add_item(character)
	
	$Tabs/Song/Characters/Opponent.text = Gameplay.SONG.song.player2
	
	var gf_version = "gf"
	match(Gameplay.SONG.song.song.to_lower()):
		"cocoa", "eggnog", "winter horrorland":
			gf_version = "gf-christmas"
		"senpai", "roses", "thorns":
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
	
	$Misc/Transition._fade_out()
	
	AudioHandler.stop_inst()
	AudioHandler.stop_voices()
	
	AudioHandler.get_node("Inst").pitch_scale = 1
	AudioHandler.get_node("Voices").pitch_scale = 1
	
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
	
	print(Gameplay.SONG.song.notes[curSection].mustHitSection)

func _process(delta):		
	if can_interact:	
		if Input.is_action_just_pressed("ui_back"):
			$Misc/Transition.transition_to_scene("MainMenu")
			
		if Input.is_action_just_pressed("ui_left"):
			change_section(-1)
			
		if Input.is_action_just_pressed("ui_right"):
			change_section(1)
			
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
			$Misc/Transition.transition_to_scene("PlayState")
			
	if playing:
		Conductor.songPosition += delta * 1000
		
		if Conductor.songPosition >= $Grid.section_start_time() + (4 * (1000 * (60 / Conductor.bpm))):
			change_section(1)
		
func change_section(amount):
	curSection += amount
	if curSection < 0:
		curSection = len(Gameplay.SONG.song.notes) - 1
	if curSection > len(Gameplay.SONG.song.notes) - 1:
		curSection = 0
		
	Conductor.songPosition = $Grid.section_start_time()
	
	AudioHandler.get_node("Inst").seek(Conductor.songPosition / 1000)
	AudioHandler.get_node("Voices").seek(Conductor.songPosition / 1000)			
	
	refresh_icons()
		
	$Grid.load_section(curSection)

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
