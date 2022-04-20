extends Node2D

var health:float = 1.0

var countdown_tween:Tween = Tween.new()
var timebar_tween:Tween = Tween.new()

var SONG

var noteDataArray = []

var gf_version:String = "gf"
var curStage:String = "stage"

var stage:Node2D

var dad:Node2D
var gf:Node2D
var boyfriend:Node2D

var dialogue_box:Node2D

var song_score:int = 0
var song_misses:int = 0

var total_notes_hit = 0

var song_accuracy:float = 0.0

var default_cam_zoom:float = 1.1

var countdown_counter:int = -1

var speed:float = 1.0

var in_cutscene:bool = true
var countdown_active:bool = true

var sing_anims = ["singLEFT", "singDOWN", "singUP", "singRIGHT"]

var marvelous:int = 0
var sicks:int = 0
var goods:int = 0
var bads:int = 0
var shits:int = 0
var misses:int = 0

var inst_time:float = 0.0
var voices_time:float = 0.0

var inst_length:float = 0.0

var can_pause:bool = false

var events = []

var loaded_modcharts = []

onready var downscroll = Options.get_data("downscroll")
onready var middlescroll = Options.get_data("middlescroll")

onready var opponent_strums = null
onready var player_strums = null

onready var game_notes = $camHUD/Notes

func _ready():
	if "events" in Gameplay.SONG.song:
		events = Gameplay.SONG.song.events.duplicate()
		
	if not "keyCount" in Gameplay.SONG.song:
		Gameplay.SONG.song.keyCount = 4
		
	if "mania" in Gameplay.SONG.song:
		match Gameplay.SONG.song.mania:
			0:
				Gameplay.SONG.song.keyCount = 4
			1:
				Gameplay.SONG.song.keyCount = 6
			2: 
				Gameplay.SONG.song.keyCount = 7
			3: 
				Gameplay.SONG.song.keyCount = 9
				
	Keybinds.setup_Binds()
				
	var loaded_o_strums = load("res://Scenes/Strums/" + str(Gameplay.SONG.song.keyCount) + "Key.tscn")
	opponent_strums = loaded_o_strums.instance()
	opponent_strums.name = "OpponentStrums"
	$camHUD.add_child(opponent_strums)
	
	var loaded_p_strums = load("res://Scenes/Strums/" + str(Gameplay.SONG.song.keyCount) + "Key.tscn")
	player_strums = loaded_p_strums.instance()
	player_strums.name = "PlayerStrums"
	$camHUD.add_child(player_strums)
	
	$camHUD.move_child(opponent_strums, 0)
	$camHUD.move_child(player_strums, 0)
	
	if Options.get_data("botplay"):
		Gameplay.used_practice = true
	else:
		Gameplay.used_practice = false
		
	if not downscroll:
		opponent_strums.global_position.y = 100
		player_strums.global_position.y = 100
		
		$camHUD/HealthBar.global_position.y = 580
		$camHUD/TimeBar.global_position.y = -660
		
		$camHUD/BotplayText.rect_position.y = 85
	else:
		opponent_strums.global_position.y = 608
		player_strums.global_position.y = 608
		
	if middlescroll:
		opponent_strums.global_position.x = -9999
		player_strums.global_position.x = ScreenRes.screen_width / 2.72
	else:
		opponent_strums.global_position.x = 0
		player_strums.global_position.x = ScreenRes.screen_width / 2
		
		var move_mult = 150
		opponent_strums.global_position.x += move_mult
		player_strums.global_position.x += move_mult
		
	# story mode shit
	if not Gameplay.story_mode:
		in_cutscene = false
	
	# pause menu shit
	AudioHandler.get_node("Inst").stream = null
	AudioHandler.get_node("Voices").stream = null
	
	if(Gameplay.SONG == null): # load tutorial if the song can't be found
		var song = "res://Assets/Songs/Tutorial/hard"
		print("SONG TO LOAD: " + song)
		Gameplay.SONG = JsonUtil.get_json(song)
		
	SONG = Gameplay.SONG.song
	
	# LOADING MODCHARTS
	
	# lists every file in the song directory
	var song_files = Util.list_files_in_directory(Paths.song_path(SONG.song))
	
	if len(song_files) <= 0:
		song_files = Util.list_files_in_directory(Paths.song_path(SONG.song.to_lower()))
		
		if len(song_files) <= 0:
			song_files = Util.list_files_in_directory(Paths.song_path(SONG.song.to_lower().replace(" ", "-")))
	
	var modchart_files = []
	
	# if the file is a .gd file and isn't a hidden file, add it
	# to modchart_files
	for file in song_files:
		if not file.begins_with(".") and ".gd" in file and not ".remap" in file:
			modchart_files.append(file)
			
	# go through each modchart file, then load and start them
	for modchart in modchart_files:
		var loaded = load(Paths.song_path(SONG.song) + "/" + modchart)
		
		if loaded != null:
			var mc = loaded.new()
			mc.PlayState = self
			loaded_modcharts.append(mc)
			add_child(mc)
		
	# don't ask
	for section in SONG["notes"]:
		for note in section["sectionNotes"]:
			if note[1] != -1:
				if len(note) == 3:
					note.push_back(0)
				
				if note[3] is Array:
					note[3] = note[3][0]
				
				noteDataArray.push_back([float(note[0]) + (Options.get_data("note-offset") + (AudioServer.get_output_latency() * 1000) * Gameplay.song_multiplier), note[1], note[2], bool(section["mustHitSection"]), int(note[3])])
	
	speed = SONG.speed
	
	if Options.get_data("scroll-speed") > 0:
		match Options.get_data("scroll-type").to_lower():
			"multiplicative":
				speed *= Options.get_data("scroll-speed")
			"constant":
				speed = Options.get_data("scroll-speed")
	
	speed /= Gameplay.song_multiplier
	
	Gameplay.scroll_speed = speed
			
	Conductor.songPosition = 0
	Conductor.curBeat = 0
	Conductor.curStep = 0
	Conductor.change_bpm(SONG.bpm, Gameplay.song_multiplier)
	Conductor.recalculate_values(Gameplay.song_multiplier)
	
	Conductor.connect("beat_hit", self, "beat_hit")
	Conductor.connect("step_hit", self, "step_hit")
	
	$Misc/Transition._fade_out()
	
	# add the stage
	var gaming_stage = "stage"
	match(Gameplay.SONG.song.song.to_lower()):
		"spookeez", "south", "monster":
			gaming_stage = "spooky"
		"pico", "philly nice", "blammed":
			gaming_stage = "philly"
		"satin panties", "high", "m.i.l.f":
			gaming_stage = "limo"
		"cocoa", "eggnog":
			gaming_stage = "mall"
			gf_version = "gf-christmas"
		"winter-horrorland":
			gaming_stage = "mallEvil"
			gf_version = "gf-christmas"
		"senpai":
			gaming_stage = "school"
			gf_version = "gf-pixel"
		"roses":
			gaming_stage = "schoolAngry"
			gf_version = "gf-pixel"
		"thorns":
			gaming_stage = "schoolEvil"
			gf_version = "gf-pixel"
		_:
			var real = "gf"
			
			if not "gfVersion" in SONG:
				real = "gf"
			else:
				real = SONG.gfVersion
				
			if not "gf" in SONG:
				real = "gf"
			else:
				real = SONG.gf
				
			if not "player3" in SONG:
				real = "gf"
			else:
				real = SONG.player3
				
			# gfVersion / gf = psych i think
			# player3 = idfk, probably used in some other engines
				
			gf_version = real
			
	curStage = gaming_stage
	
	if "stage" in SONG:
		curStage = SONG.stage
			
	var stageLoaded = load("res://Stages/" + curStage + "/stage.tscn")
	
	if stageLoaded == null:
		stageLoaded = load("res://Stages/stage/stage.tscn")
	
	stage = stageLoaded.instance()
	$Stage.add_child(stage)
	
	default_cam_zoom = stage.default_cam_zoom
	
	# add gf
	var gfLoaded = load("res://Characters/" + gf_version.to_lower() + "/char.tscn")
	
	if gfLoaded == null:
		gfLoaded = load("res://Characters/gf/char.tscn")
	
	gf = gfLoaded.instance()
	gf.name = "gf"
	gf.global_position = stage.get_node("gf_pos").position
	
	# add dad
	var dadLoaded = load("res://Characters/" + SONG.player2.to_lower() + "/char.tscn")
	
	if dadLoaded == null:
		dadLoaded = load("res://Characters/bf/char.tscn")
	
	dad = dadLoaded.instance()
	dad.name = "dad"
	dad.global_position = stage.get_node("dad_pos").position
	
	if dad.is_player:
		dad.is_player = false
		dad.get_node("camera_pos").position.x *= -1
		dad.get_node("frames").flip_h = true
	
	if dadLoaded == gfLoaded:
		dad.global_position = stage.get_node("gf_pos").position
		gf.visible = false
	
	# add boyfriend
	var bfLoaded = load("res://Characters/" + SONG.player1.to_lower() + "/char.tscn")
	
	if bfLoaded == null:
		bfLoaded = load("res://Characters/bf/char.tscn")
	
	boyfriend = bfLoaded.instance()
	boyfriend.name = "boyfriend"
	boyfriend.global_position = stage.get_node("bf_pos").position
	
	$Characters.add_child(gf)
	$Characters.add_child(dad)
	$Characters.add_child(boyfriend)
	
	$camHUD/TimeBar/FGColor.color = dad.health_color
	$camGame.position = dad.global_position + dad.get_node("camera_pos").position
	
	change_dad_icon(dad.health_icon)
	change_bf_icon(boyfriend.health_icon)
	
	change_dad_health_color(dad.health_color)
	change_bf_health_color(boyfriend.health_color)
	
	$camGame.zoom = Vector2(default_cam_zoom, default_cam_zoom)
	
	#generate_notes()
	# now this is stupid, we're gonna generate the notes as the song goes now
	
	Conductor.songPosition = (Conductor.timeBetweenBeats * -5)
	
func change_dad_icon(texture):
	$camHUD/HealthBar/IconP2.texture = texture
	
func change_bf_icon(texture):
	$camHUD/HealthBar/IconP1.texture = texture
	
func change_dad_health_color(color):
	$camHUD/HealthBar/DadColor.color = color
	
func change_bf_health_color(color):
	$camHUD/HealthBar/BFColor.color = color
	
var botplay_text_sine = 0.0

func _process(delta):
	if not in_cutscene and not ending_song:
		if not countdown_active:
			Conductor.songPosition += (delta * 1000) * Gameplay.song_multiplier
		else:
			Conductor.songPosition += (delta * 1000)
		
	if Input.is_action_just_pressed("chart_editor"):		
		$Misc/Transition.transition_to_scene("ChartEditor")
	
	$camHUD/BotplayText.visible = Options.get_data("botplay")
	
	botplay_text_sine += 180 * delta;
	$camHUD/BotplayText.modulate.a = 1 - sin((PI * botplay_text_sine) / 180);
	
	if $camHUD/BotplayText.modulate.a > 1:
		$camHUD/BotplayText.modulate.a = 1
	
	if not countdown_active:
		inst_time = AudioHandler.get_node("Inst").get_playback_position() * 1000
		voices_time = AudioHandler.get_node("Voices").get_playback_position() * 1000
		
		inst_length = AudioHandler.get_node("Inst").stream.get_length() * 1000
		
		#print(format_time(time / 1000, false))
		$camHUD/TimeBar/TimeText.text = Util.format_time((inst_time / 1000) / Gameplay.song_multiplier, false) + " / " + Util.format_time((inst_length / 1000) / Gameplay.song_multiplier, false)
		
		$camHUD/TimeBar/FGColor.rect_scale.x = (inst_time / inst_length)

		if Conductor.songPosition >= inst_length:
			check_for_achievements()

	$camHUD/HealthBar/ScoreText.bbcode_text = "[center]Score: " + str(song_score) + " // Misses: " + str(song_misses) + " // Accuracy: " + str(Util.round_decimal(song_accuracy * 100, 2)) + "%"
	
	if Options.get_data("botplay"):
		$camHUD/HealthBar/ScoreText.bbcode_text += " // BOTPLAY"
		$camHUD/TimeBar/TimeText.text += " [BOT]"
	
	$camHUD/HealthBar/BFColor.rect_scale.x = health / 2
	
	var index = 0
	for note in noteDataArray:
		if float(note[0]) > Conductor.songPosition + 5000:
			break
			
		if float(note[0]) - Conductor.songPosition < (1500 * Gameplay.song_multiplier):
			var dunceNote:Node2D = load("res://Scenes/Notes/Default/Note.tscn").instance()
			dunceNote.strumTime = note[0]
			dunceNote.noteData = int(note[1]) % Gameplay.SONG.song.keyCount
			dunceNote.sustainLength = note[2]
			
			if dunceNote.sustainLength <= 50:
				dunceNote.sustainLength = 0
			
			dunceNote.mustPress = true
			
			dunceNote.set_direction()
			
			if note[3] and int(note[1]) % (Gameplay.SONG.song.keyCount * 2) >= Gameplay.SONG.song.keyCount:
				dunceNote.mustPress = false
			elif !note[3] and int(note[1]) % (Gameplay.SONG.song.keyCount * 2) <= Gameplay.SONG.song.keyCount - 1:
				dunceNote.mustPress = false
				
			if not dunceNote.mustPress:
				dunceNote.scale = opponent_strums.scale
			else:
				dunceNote.scale = player_strums.scale
				
			dunceNote.get_node("Line2D").texture = load("res://Assets/Images/UI Skins/" + Gameplay.ui_Skin + "/Sustains/" + dunceNote.dir_string + " hold0000.png")
			dunceNote.get_node("End").texture = load("res://Assets/Images/UI Skins/" + Gameplay.ui_Skin + "/Sustains/" + dunceNote.dir_string + " tail0000.png")
			
			game_notes.add_child(dunceNote)
			
			if dunceNote.mustPress:
				dunceNote.global_position.x = player_strums.get_children()[int(note[1]) % Gameplay.SONG.song.keyCount].global_position.x
			else:
				dunceNote.global_position.x = opponent_strums.get_children()[int(note[1]) % Gameplay.SONG.song.keyCount].global_position.x
				
			noteDataArray.remove(index)
	
		index += 1
		
	for event in events:
		if Conductor.songPosition >= event[0]:
			for piss in event[1]:
				var event_name = piss[0]
				var value1 = piss[1]
				var value2 = piss[2]
				
				match event_name:
					"Change Stage":
						$Stage.remove_child(stage)
					"Change Character":
						$Characters.remove_child(dad)
						$Characters.remove_child(gf)
						$Characters.remove_child(boyfriend)
						
						match value1:
							"dad", _:
								var dadLoaded = load("res://Characters/" + value2 + "/char.tscn")
		
								if dadLoaded == null:
									dadLoaded = load("res://Characters/bf/char.tscn")
								
								dad = dadLoaded.instance()
								dad.name = "dad"
								dad.global_position = stage.get_node("dad_pos").position
								
								change_dad_health_color(dad.health_color)
								change_dad_icon(dad.health_icon)
							"gf":
								var gfLoaded = load("res://Characters/" + value2 + "/char.tscn")
		
								if gfLoaded == null:
									gfLoaded = load("res://Characters/gf/char.tscn")
								
								gf = gfLoaded.instance()
								gf.name = "gf"
								gf.global_position = stage.get_node("gf_pos").position
							"bf":
								var bfLoaded = load("res://Characters/" + value2 + "/char.tscn")
		
								if bfLoaded == null:
									bfLoaded = load("res://Characters/bf/char.tscn")
								
								boyfriend = bfLoaded.instance()
								boyfriend.name = "boyfriend"
								boyfriend.global_position = stage.get_node("bf_pos").position
								
								change_bf_health_color(boyfriend.health_color)
								change_bf_icon(boyfriend.health_icon)
							
						$Characters.add_child(gf)
						$Characters.add_child(dad)
						$Characters.add_child(boyfriend)
				
			events.remove(0)
			
	if health < 0.4150:
		$camHUD/HealthBar/IconP2.frame = 2
		$camHUD/HealthBar/IconP1.frame = 1
	else:
		$camHUD/HealthBar/IconP2.frame = 0
		$camHUD/HealthBar/IconP1.frame = 0
		
	if health > 1.625:
		$camHUD/HealthBar/IconP2.frame = 1
		$camHUD/HealthBar/IconP1.frame = 2
			
	for note in game_notes.get_children():
		var strum
		if note.mustPress:
			strum = player_strums.get_children()[note.noteData % Gameplay.SONG.song.keyCount]
		else:
			strum = opponent_strums.get_children()[note.noteData % Gameplay.SONG.song.keyCount]
			
		note.global_position.x = strum.global_position.x
			
		if downscroll:
			note.global_position.y = strum.global_position.y + (0.45 * (Conductor.songPosition - note.strumTime) * Util.round_decimal(speed, 2))
		else:
			note.global_position.y = strum.global_position.y + (-0.45 * (Conductor.songPosition - note.strumTime) * Util.round_decimal(speed, 2))
			
		# opponent notes
		if not note.mustPress:
			if not countdown_active:
				if Conductor.songPosition >= note.strumTime:
					#AudioHandler.get_node("Voices").play()
					#AudioHandler.get_node("Voices").seek(AudioHandler.get_node("Inst").get_playback_position())
					
					if dad.special_anim != true:
						dad.hold_timer = 0
						dad.play_anim(sing_anims[note.noteData % 4], true)
						
					for modchart in loaded_modcharts:
						if modchart.opponent_note_hit(note.noteData % Gameplay.SONG.song.keyCount) != null:
							modchart.opponent_note_hit(note.noteData % Gameplay.SONG.song.keyCoun)
					
					AudioHandler.get_node("Voices").volume_db = 0
					
					strum.frame = 0
					strum.play(Gameplay.note_letter_directions[Gameplay.SONG.song.keyCount - 1][note.noteData % Gameplay.SONG.song.keyCount] + " confirm")
					note.get_node("Note").visible = false
					
					note.global_position.y = strum.global_position.y
					note.sustainLength -= (delta * 1000) * Gameplay.song_multiplier
					if note.sustainLength <= 0:
						note.queue_free()

			
		# missing
		
		# made it so you don't get a miss for releasing
		# a sustain ever so slightly early
		
		# edit this to edit how early you can release without
		# getting punished
		var sustainMissRange = 100
		
		var your = (note.mustPress and note.sustainLength <= 0 and not Options.get_data("botplay"))
		var your2 = (note.mustPress and note.sustainLength >= 0 and not pressed[note.noteData % Gameplay.SONG.song.keyCount] and not Options.get_data("botplay"))
		
		if note.beingPressed and note.sustainLength <= sustainMissRange:
			note.sustainLength -= (delta * 1000) * Gameplay.song_multiplier
			note.global_position.y = player_strums.get_children()[note.noteData % Gameplay.SONG.song.keyCount].global_position.y
			
			if note.sustainLength <= 0:
				note.queue_free()
		else:
			if your or your2:
				if Conductor.songPosition > note.strumTime + Conductor.safeZoneOffset:
					song_score -= 10
					song_misses += 1
					#total_notes_hit += 1
					combo = 0
					
					if note.sustainLength >= 150:
						health -= 0.2475
					else:
						health -= 0.0475
						
					AudioHandler.play_audio("missnote" + str(randi()%3 + 1))
					
					calculate_accuracy()
					
					if boyfriend.special_anim != true:
						boyfriend.play_anim(sing_anims[note.noteData % 4] + "miss", true)
					
					AudioHandler.get_node("Voices").volume_db = -999
					note.queue_free()
			
	var strum_confirm_i = 0
	for strum in opponent_strums.get_children():
		if strum.frame == 3:
			strum.play("arrow" + directions[strum_confirm_i])
			
		strum_confirm_i += 1
		
	# countdown shit
	if countdown_active:
		var prev_counter = countdown_counter
		
		if Conductor.songPosition >= Conductor.timeBetweenBeats * -4:
			countdown_counter = 0
		if Conductor.songPosition >= Conductor.timeBetweenBeats * -3:
			countdown_counter = 1
		if Conductor.songPosition >= Conductor.timeBetweenBeats * -2:
			countdown_counter = 2
		if Conductor.songPosition >= Conductor.timeBetweenBeats * -1:
			countdown_counter = 3
		if Conductor.songPosition >= 0:
			countdown_counter = 4
			
		if prev_counter != countdown_counter:
			match(countdown_counter):
				0:
					AudioHandler.play_countdown(countdown_counter)
					can_pause = true
				1:
					AudioHandler.play_countdown(countdown_counter)
					
					var ready = load("res://Scenes/Gameplay/Ready.tscn").instance()
					ready.texture = load("res://Assets/Images/UI Skins/" + Gameplay.ui_Skin + "/ready.png")
					countdown_tween.interpolate_property(ready, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), (Conductor.timeBetweenBeats / 1000), Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
					add_child(countdown_tween)
					countdown_tween.start()
					$camHUD.add_child(ready)
				2:
					AudioHandler.play_countdown(countdown_counter)
					
					var set = load("res://Scenes/Gameplay/Set.tscn").instance()
					set.texture = load("res://Assets/Images/UI Skins/" + Gameplay.ui_Skin + "/set.png")
					countdown_tween.interpolate_property(set, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), (Conductor.timeBetweenBeats / 1000), Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
					countdown_tween.start()
					$camHUD.add_child(set)
				3:
					AudioHandler.play_countdown(countdown_counter)
					
					var go = load("res://Scenes/Gameplay/Go.tscn").instance()
					go.texture = load("res://Assets/Images/UI Skins/" + Gameplay.ui_Skin + "/go.png")
					countdown_tween.interpolate_property(go, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), (Conductor.timeBetweenBeats / 1000), Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
					countdown_tween.start()
					$camHUD.add_child(go)
				4:
					AudioHandler.stop_audio("freakyMenu")
					
					AudioHandler.play_inst(SONG.song)
					AudioHandler.play_voices(SONG.song)
					
					AudioHandler.get_node("Inst").seek(0)
					AudioHandler.get_node("Voices").seek(0)
					
					AudioHandler.get_node("Inst").volume_db = 0
					AudioHandler.get_node("Voices").volume_db = 0
					
					AudioHandler.get_node("Inst").pitch_scale = Gameplay.song_multiplier
					AudioHandler.get_node("Voices").pitch_scale = Gameplay.song_multiplier
					
					Conductor.songPosition = 0.0
					countdown_active = false
		
					timebar_tween.interpolate_property($camHUD/TimeBar, "modulate", $camHUD/TimeBar.modulate, Color(1, 1, 1, 1), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
					add_child(timebar_tween)
					timebar_tween.start()
				
	if not in_cutscene:	
		key_shit(delta)
	
	if not pressed.has(true):
		if boyfriend.hold_timer > Conductor.timeBetweenSteps * 0.001 * boyfriend.sing_duration and boyfriend.get_node("frames").animation.begins_with("sing") and not boyfriend.get_node("frames").animation.ends_with("miss"):
			boyfriend.dance()
	else:
		boyfriend.hold_timer = 0
	
	for note in game_notes.get_children():
		if note.mustPress and note.sustainLength > 0 and pressed[note.noteData % Gameplay.SONG.song.keyCount] and Conductor.songPosition >= note.strumTime or Options.get_data("botplay") and note.mustPress and note.sustainLength > 0 and Conductor.songPosition >= note.strumTime:
			var strum = player_strums.get_children()[note.noteData % Gameplay.SONG.song.keyCount]
			
			strum.frame = 0
			strum.play(Gameplay.note_letter_directions[Gameplay.SONG.song.keyCount - 1][note.noteData % Gameplay.SONG.song.keyCount] + " confirm")
			
			if boyfriend.special_anim != true:
				boyfriend.play_anim(sing_anims[note.noteData % 4], true)
				
			for modchart in loaded_modcharts:
				if modchart.player_note_hit(note.noteData % Gameplay.SONG.song.keyCount) != null:
					modchart.player_note_hit(note.noteData % Gameplay.SONG.song.keyCount)
			
			AudioHandler.get_node("Voices").volume_db = 0
			
			if Options.get_data("pussy-mode"):
				health += delta / 4
			
			note.get_node("Note").visible = false
			note.global_position.y = strum.global_position.y
			note.sustainLength -= (delta * 1000) * Gameplay.song_multiplier
			if note.sustainLength <= 0:
				note.queue_free()
				
	if health <= 0:
		health = 0
		Gameplay.death_character = boyfriend.death_character
		Gameplay.death_character_pos = boyfriend.global_position
		Gameplay.death_camera_pos = $camGame.position
		
		Gameplay.blueballed += 1
		
		SceneManager.switch_scene("Gameover")
		
	if health > 2:
		health = 2
	
	camera_zooms(delta)
	icon_zooms(delta)
	
var ending_song = false

var balls = false

var fuck_you_lmao = false

func check_for_achievements():
	ending_song = true
	can_pause = false
		
	if not fuck_you_lmao:
		fuck_you_lmao = true
		
		for achievement in Achievements.achievements.keys():
			check_for_achievement(achievement)
		
		AchievementThingie.unlock_achievements()
	
	if not AchievementThingie.listing_shit and not balls:
		balls = true
		end_song(true)
			
func check_for_achievement(achievement):
	var unlock = false
	
	if Achievements.achievements[achievement].unlocks_after_week != "":
		if Gameplay.story_mode and not Gameplay.used_practice:
			match Achievements.achievements[achievement].internal_name:
				"tutorial":
					unlock = true
	else:
		match Achievements.achievements[achievement].internal_name:
			_:
				pass # nothing here rn lo
					
	if unlock:
		Achievements.unlock(achievement)
		
func end_song(force = false):
	if not ending_song or force:
		ending_song = true
		can_pause = false
		
		if not Gameplay.used_practice and not Options.get_data("pussy-mode") and Gameplay.song_multiplier >= 1:
			if(song_score > SongHighscore.get_score(SONG.song.to_lower().replace(" ", "-") + "-" + Gameplay.difficulty)):
				SongHighscore.set_score(SONG.song.to_lower().replace(" ", "-") + "-" + Gameplay.difficulty, song_score)
				SongAccuracy.set_acc(SONG.song.to_lower().replace(" ", "-") + "-" + Gameplay.difficulty, Util.round_decimal(song_accuracy * 100, 2))
				
		if Gameplay.story_mode:
			Gameplay.story_playlist.remove(0)
			
			if not Gameplay.used_practice and not Options.get_data("pussy-mode") and Gameplay.song_multiplier >= 1:
				Gameplay.story_score += song_score
			
			if len(Gameplay.story_playlist) > 0:
				var song = "res://Assets/Songs/" + Gameplay.story_playlist[0] + "/" + Gameplay.difficulty
				Gameplay.SONG = JsonUtil.get_json(song)
				get_tree().reload_current_scene()
			else:
				if Gameplay.song_multiplier >= 1:
					if Gameplay.story_score > WeekHighscore.get_score(Gameplay.week_name):
						WeekHighscore.set_score(Gameplay.week_name, Gameplay.story_score)
				
				AudioHandler.play_audio("freakyMenu")
				$Misc/Transition.transition_to_scene("StoryMenu")
		else:
			AudioHandler.play_audio("freakyMenu")			
			$Misc/Transition.transition_to_scene("FreeplayMenu")
			
	AudioHandler.stop_inst()
	AudioHandler.stop_voices()
	
func camera_zooms(delta):
	# cam game zoom
	var camGameZoomX = lerp($camGame.zoom.x, default_cam_zoom, delta * 7)
	var camGameZoomY = lerp($camGame.zoom.y, default_cam_zoom, delta * 7)
	
	$camGame.zoom = Vector2(camGameZoomX, camGameZoomY)
	
	# cam hud zoom
	var camHUDZoom = lerp($camHUD.scale, Vector2(1, 1), delta * 7)
	
	$camHUD.scale = camHUDZoom
	$camHUD.offset.x = (camHUDZoom.x - 1) * -640
	$camHUD.offset.y = (camHUDZoom.x - 1) * -360
	
func icon_zooms(delta):
	var iconScaleX = lerp($camHUD/HealthBar/IconP2.scale.x, 1, delta * 15)
	var iconScaleY = lerp($camHUD/HealthBar/IconP2.scale.y, 1, delta * 15)
	
	$camHUD/HealthBar/IconP2.scale = Vector2(iconScaleX, iconScaleY)
	$camHUD/HealthBar/IconP1.scale = Vector2(0 - iconScaleX, iconScaleY)
	
	var iconOffset:int = 26
	var healthBar = $camHUD/HealthBar/BFColor
	
	var healthPercentage = (health / 2) * 100
	
	$camHUD/HealthBar/IconP1.position.x = ((healthBar.rect_position.x + healthBar.rect_pivot_offset.x) - ((healthBar.rect_scale.x * 600) - 60)) + ((abs($camHUD/HealthBar/IconP1.scale.x) - 1) * 80)
	$camHUD/HealthBar/IconP2.position.x = ($camHUD/HealthBar/IconP1.position.x - 105) - ((abs($camHUD/HealthBar/IconP1.scale.x) - 1) * 150)
	
var cur_rating = "marvelous"

var just_pressed = [false, false, false, false]
var just_released = [false, false, false, false]
var pressed = [false, false, false, false]
var released = [false, false, false, false]

var hits = 0

var directions = ["LEFT", "DOWN", "UP", "RIGHT"]
var letter_directions = ["A", "B", "C", "D"]

var combo = 0
	
var brum = 0
	
func key_shit(delta):	
	just_pressed = []
	just_released = []
	pressed = []
	released = []
	
	for i in Gameplay.SONG.song.keyCount:
		just_pressed.append(false)
		just_released.append(false)
		pressed.append(false)
		released.append(false)
	
	if not Options.get_data("botplay"):
		for i in Gameplay.SONG.song.keyCount:
			just_pressed[i] = Input.is_action_just_pressed("gameplay_" + str(i))
			pressed[i] = Input.is_action_pressed("gameplay_" + str(i))
			released[i] = not Input.is_action_pressed("gameplay_" + str(i))
			
		for i in len(just_pressed):
			if just_pressed[i] == true:
				player_strums.get_children()[i].play(Gameplay.note_letter_directions[Gameplay.SONG.song.keyCount - 1][i] + " press")
				
		for i in len(released):
			if released[i] == true:
				player_strums.get_children()[i].play("arrow" + Gameplay.note_directions[Gameplay.SONG.song.keyCount - 1][i])
	else:
		for i in len(released):
			if player_strums.get_children()[i].frame == 3:
				player_strums.get_children()[i].play("arrow" + Gameplay.note_directions[Gameplay.SONG.song.keyCount - 1][i])
		
	var possibleNotes = []
	
	for note in game_notes.get_children():
		note.calculate_can_be_hit()
		
		if not Options.get_data("botplay"):
			if note.canBeHit and note.mustPress and not note.tooLate and not note.isSustainNote:
				possibleNotes.append(note)
		else:
			if note.strumTime <= Conductor.songPosition and note.mustPress:
				possibleNotes.append(note)
	
	var dont_hit = []
	var note_data_times = []
	
	for i in Gameplay.SONG.song.keyCount:
		dont_hit.append(false)
		note_data_times.append(-1)
	
	if len(possibleNotes) > 0:
		for i in len(possibleNotes):
			var note = possibleNotes[i]
			
			if (just_pressed[note.noteData % Gameplay.SONG.song.keyCount] and not dont_hit[note.noteData % Gameplay.SONG.song.keyCount] and not Options.get_data("botplay")) or Options.get_data("botplay"):
				if not note.beingPressed:
					var rating_scores = [350, 200, 100, 50]
					
					var note_ms = (Conductor.songPosition - note.strumTime) / Gameplay.song_multiplier
					
					if Options.get_data("botplay"):
						note_ms = 0
						
					note_ms = Util.round_decimal(note_ms, 3)
					
					var judgement_timings = [
						Options.get_data("sick-timing"), # sick
						Options.get_data("good-timing"), # good
						Options.get_data("bad-timing"), # bad
						Options.get_data("shit-timing") # shit
					]
					
					cur_rating = "marvelous"
					
					if abs(note_ms) > judgement_timings[0]:
						cur_rating = "sick"
						song_score += rating_scores[0]
						
					if abs(note_ms) > judgement_timings[1]:
						cur_rating = "good"
						song_score += rating_scores[1]
					
					if abs(note_ms) > judgement_timings[2]:
						cur_rating = "bad"
						song_score += rating_scores[2]
						
					if abs(note_ms) > judgement_timings[3]:
						cur_rating = "shit"
						song_score += rating_scores[3]
						
					if cur_rating == "marvelous":
						song_score += rating_scores[0]
						
					if not Options.get_data("hitsound") == "None":
						AudioHandler.play_hitsound(Options.get_data("hitsound"))
						
					var rating = preload("res://Scenes/Gameplay/Rating.tscn").instance()
					rating.name = "Rating" + str(hits)
					rating.get_node("Sprite").texture = load("res://Assets/Images/UI Skins/" + Gameplay.ui_Skin + "/" + cur_rating + ".png")
					rating.modulate.a = 1
					rating.visible = true
					rating.note_ms = note_ms
					rating.combo = combo
					hits += 1
					combo += 1
						
					match(cur_rating):
						"marvelous", "sick":
							rating.get_node("MS").modulate = Color("42bcf5")
							total_notes_hit += 1
							
							if cur_rating == "marvelous":
								marvelous += 1
							else:
								sicks += 1
							
							if Options.get_data("note-splashes"):
								var note_splash = preload("res://Scenes/Gameplay/NoteSplash.tscn").instance()
								note_splash.noteData = note.noteData % Gameplay.SONG.song.keyCount
								note_splash.global_position = player_strums.get_children()[note.noteData % Gameplay.SONG.song.keyCount].global_position
								$camHUD.add_child(note_splash)
						"good":
							rating.get_node("MS").modulate = Color("42f584")
							total_notes_hit += 0.75
							goods += 1
						"bad":
							rating.get_node("MS").modulate = Color("f59e42")
							total_notes_hit += 0.5
							bads += 1
						"shit":
							rating.get_node("MS").modulate = Color("f54242")
							total_notes_hit += 0
							shits += 1
							
							if not Options.get_data("pussy-mode"):
								health -= 0.2
								
					for rating_spr in $camHUD/Ratings.get_children():
						rating_spr.get_node("MS").visible = false

					$camHUD/Ratings.add_child(rating)
					
					calculate_accuracy()
					
					health += 0.023
					
					dont_hit[note.noteData % Gameplay.SONG.song.keyCount] = true
					pressed[note.noteData % Gameplay.SONG.song.keyCount] = true
					
					if boyfriend.special_anim != true:
						boyfriend.play_anim(sing_anims[note.noteData % 4], true)
					
					AudioHandler.get_node("Voices").volume_db = 0
					
					var strum = player_strums.get_children()[note.noteData % Gameplay.SONG.song.keyCount]
					strum.play(Gameplay.note_letter_directions[Gameplay.SONG.song.keyCount - 1][note.noteData % Gameplay.SONG.song.keyCount] + " confirm")
					
					note.get_node("Note").visible = false
					
					if note.sustainLength <= 0:
						note.queue_free()
						
					for modchart in loaded_modcharts:
						if modchart.player_note_hit(note.noteData % Gameplay.SONG.song.keyCount) != null:
							modchart.player_note_hit(note.noteData % Gameplay.SONG.song.keyCount)
						
					for real in possibleNotes:
						if real.noteData == note.noteData:
							if real.sustainLength <= 0 and floor(real.strumTime) == floor(note.strumTime):
								real.queue_free()
					
					if note.sustainLength > 0:
						note.beingPressed = true
						
	for i in len(just_pressed):
		if just_pressed[i] == true:
			if not Options.get_data("ghost-tapping") and not dont_hit[i]:
				song_score -= 10
				song_misses += 1
				#total_notes_hit += 1
				combo = 0
				
				health -= 0.0475
					
				if not boyfriend.special_anim:
					boyfriend.play_anim(sing_anims[i] + "miss")
					
				AudioHandler.play_audio("missnote" + str(randi()%3 + 1))
				
				calculate_accuracy()
					
func calculate_accuracy():
	if (hits + song_misses) > 0:
		song_accuracy = min(1, max(0, total_notes_hit / (hits + song_misses)))
		
	$camHUD/RatingText.text = "Marvelous: " + str(marvelous)
	$camHUD/RatingText.text += "\nSicks: " + str(sicks)
	$camHUD/RatingText.text += "\nGoods: " + str(goods)
	$camHUD/RatingText.text += "\nBads: " + str(bads)
	$camHUD/RatingText.text += "\nShits: " + str(shits)
	$camHUD/RatingText.text += "\nMisses: " + str(song_misses)
				
func sort_notes(a, b):
	return sort_by_values(-1, a.strumTime, b.strumTime)
	
func sort_by_values(Order, Value1, Value2):
	var result:int = 0

	if (Value1 < Value2):
		result = Order
	elif (Value1 > Value2):
		result = -Order
		
	return result
	
func beat_hit():
	if boyfriend != null:
		if boyfriend.is_dancing() or boyfriend.last_anim.ends_with("miss") or boyfriend.last_anim == "hey" or boyfriend.last_anim == "scared":
			boyfriend.dance()
			
	if dad != null:
		if dad.is_dancing() or (SONG.player2 == gf_version and dad.last_anim == "cheer" or dad.last_anim == "scared"):
			dad.dance()
			
	if gf != null:
		if (gf.is_dancing() or gf.last_anim == "cheer" or gf.last_anim == "scared" or (gf.last_anim == "hairFall" and gf.get_node("anim").current_animation == "")) and dad != gf:
			gf.dance()
			
	if not countdown_active:
		$camHUD/HealthBar/IconP2.scale = Vector2(1.2, 1.2)
		$camHUD/HealthBar/IconP1.scale = Vector2(-1.2, 1.2)
		
		if Conductor.curBeat % 4 == 0:
			$camGame.zoom = Vector2(default_cam_zoom, default_cam_zoom) * 0.98
			$camHUD.scale = Vector2(1.03, 1.03)
			
	# HARDCODED EVENTS UNTIL I ADD UNHARDCODED ONES!!!
	if Conductor.curBeat % 8 == 7 && SONG.song.to_lower() == 'bopeebo':
		boyfriend.play_anim('hey', true)
		boyfriend.special_anim = true

	if Conductor.curBeat % 16 == 15 && SONG.song.to_lower() == 'tutorial' && Conductor.curBeat > 16 && Conductor.curBeat < 48:
		boyfriend.play_anim('hey', true)
		boyfriend.special_anim = true
		
		dad.play_anim('cheer', true)
		dad.special_anim = true
	
	elif Conductor.curBeat % 16 == 15 && SONG.song.to_lower() == 'tutorial' && Conductor.curBeat > 16 && Conductor.curBeat < 48:
		boyfriend.play_anim('hey', true)
		boyfriend.special_anim = true
		
		gf.play_anim('cheer', true)
		gf.special_anim = true

var curSection:int = 0

var mustHitSection = false

func resync_vocals():
	Conductor.songPosition = (AudioHandler.get_node("Inst").get_playback_position() * 1000)
	AudioHandler.get_node("Voices").seek(Conductor.songPosition / 1000)

func step_hit():
	if not countdown_active:
		var gaming = 20
		
		if OS.get_name() == "Windows":
			gaming = 30
		
		# this was supposed to be song multiplier, i'm a dumbass.
		if Gameplay.song_multiplier >= 1:
			gaming *= Gameplay.song_multiplier
		
		if not ending_song and abs(inst_time + (AudioServer.get_time_since_last_mix() * 1000) - (Conductor.songPosition)) > gaming || (SONG.needsVoices && abs(voices_time + (AudioServer.get_time_since_last_mix() * 1000) - (Conductor.songPosition)) > gaming):
			resync_vocals()
		
	var prevSection = curSection

	curSection = floor(Conductor.curStep / 16)
	
	if curSection != prevSection:
		if len(SONG["notes"]) - 1 >= curSection:
			if SONG["notes"][curSection]["mustHitSection"]:
				mustHitSection = true
				$camHUD/TimeBar/FGColor.color = boyfriend.health_color
				$camGame.position = boyfriend.global_position + boyfriend.get_node("camera_pos").position
			else:
				mustHitSection = false
				$camHUD/TimeBar/FGColor.color = dad.health_color
				$camGame.position = dad.global_position + dad.get_node("camera_pos").position
