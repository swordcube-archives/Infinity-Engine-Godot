extends Node2D

var noteDataArray = []

var speed = 1.0

var countdown_active = true
var ending_song = false
var in_cutscene = false
var can_pause = true

var cam_zooming = false

var default_cam_zoom = 1

var timebar_tween:Tween = Tween.new()

onready var cam_hud = $camHUD
onready var health_bar = $camHUD/HealthBar
onready var cam_game = $camGame
onready var characters = $Characters

onready var downscroll = Options.get_data("downscroll")
onready var middlescroll = Options.get_data("middlescroll")

var opponent_strums = null
var player_strums = null
onready var game_notes = $camHUD/Notes

onready var icon_p2 = $camHUD/HealthBar/IconP2
onready var icon_p1 = $camHUD/HealthBar/IconP1

var cur_stage = "stage"
var gf_version = "gf"

var stage = null

var dad = null
var bf = null
var gf = null

var song_score = 0
var song_misses = 0
var song_accuracy = 0.0

var total_notes_hit = 0.0

var combo = 0

var hits = 0

var marvelous = 0
var sicks = 0
var goods = 0
var bads = 0
var shits = 0

var loaded_modcharts = []

var sing_anims_list = [
	["singUP"],
	["singLEFT", "singRIGHT"],
	["singLEFT", "singUP", "singRIGHT"],
	["singLEFT", "singDOWN", "singUP", "singRIGHT"],
	["singLEFT", "singDOWN", "singUP", "singUP", "singRIGHT"],
	["singLEFT", "singDOWN", "singRIGHT", "singLEFT", "singUP", "singRIGHT"],
	["singLEFT", "singDOWN", "singRIGHT", "singUP", "singLEFT", "singUP", "singRIGHT"],
	["singLEFT", "singDOWN", "singUP", "singRIGHT", "singLEFT", "singDOWN", "singUP", "singRIGHT"],
	["singLEFT", "singDOWN", "singUP", "singRIGHT", "singUP", "singLEFT", "singDOWN", "singUP", "singRIGHT"],
]

var sing_anims = []

var health = 1.0

var cur_section = 0

var inst_time = 0.0
var inst_length = 0.0

var voices_time = 0.0

func _ready():
	Conductor.songPosition = Conductor.timeBetweenBeats * -4.5
	Conductor.curBeat = 0
	Conductor.curStep = 0
	Conductor.change_bpm(Gameplay.SONG.song.bpm, Gameplay.song_multiplier)
	Conductor.recalculate_values(Gameplay.song_multiplier)
	
	Conductor.connect("beat_hit", self, "beat_hit")
	Conductor.connect("step_hit", self, "step_hit")
	
	Keybinds.setup_Binds()
	
	$Misc/Transition._fade_out()
	
	opponent_strums = load("res://Scenes/Strums/" + str(Gameplay.key_count) + "Key.tscn").instance()
	cam_hud.add_child(opponent_strums)
	
	player_strums = load("res://Scenes/Strums/" + str(Gameplay.key_count) + "Key.tscn").instance()
	cam_hud.add_child(player_strums)
	
	cam_hud.move_child(opponent_strums, 0)
	cam_hud.move_child(player_strums, 0)
	
	position_strums()
	
	load_stage()
	load_characters()
	load_notes()
	
	var zoomThing = 1 - stage.default_cam_zoom
	var goodZoom = 1 + zoomThing
	
	cam_game.zoom = Vector2(goodZoom, goodZoom)
	default_cam_zoom = goodZoom
	
	tween_arrows_in()
	reload_health_bar()
	
func reload_health_bar():
	$camHUD/HealthBar/DadColor.color = dad.health_color
	$camHUD/HealthBar/BFColor.color = bf.health_color
	
	icon_p2.texture = dad.health_icon
	icon_p1.texture = bf.health_icon
	
func load_stage():
	gf_version = "gf"
	
	var cur_stage = "stage"
	if "stage" in Gameplay.SONG.song:
		cur_stage = Gameplay.SONG.song.stage
	else:
		match Gameplay.SONG.song.song.to_lower():
			"spookeez", "south", "monster":
				cur_stage = "spooky"
			"pico", "philly nice", "blammed":
				cur_stage = "philly"
			"satin panties", "high", "m.i.l.f":
				gf_version = "gf-car"
				cur_stage = "limo"
			"cocoa", "eggnog":
				gf_version = "gf-christmas"
				cur_stage = "mall"
			"winter horrorland":
				gf_version = "gf-christmas"
				cur_stage = "mallEvil"
			"senpai":
				gf_version = "gf-pixel"
				cur_stage = "school"
			"roses":
				gf_version = "gf-pixel"
				cur_stage = "schoolAngry"
			"thorns":
				gf_version = "gf-pixel"
				cur_stage = "schoolEvil"
			_:
				cur_stage = "stage"
				
	Gameplay.SONG.song.stage = cur_stage

	var stage_loaded = load(Paths.stage(cur_stage))
	if stage_loaded == null:
		stage_loaded = load(Paths.stage("stage"))
		
	stage = stage_loaded.instance()
	$Stage.add_child(stage)
	
func load_characters():
	var dad_loaded = load(Paths.character(Gameplay.SONG.song.player2))
	if dad_loaded == null:
		dad_loaded = load(Paths.character("bf"))
		
	var gf_loaded = load(Paths.character(gf_version))
	if gf_loaded == null:
		gf_loaded = load(Paths.character("gf"))
		
	var bf_loaded = load(Paths.character(Gameplay.SONG.song.player1))
	if bf_loaded == null:
		bf_loaded = load(Paths.character("bf"))	
	
	dad = dad_loaded.instance()
	gf = gf_loaded.instance()
	bf = bf_loaded.instance()
	
	dad.global_position = stage.get_node("dad_pos").position
	
	if dad_loaded == gf_loaded:
		gf.visible = false
		dad.global_position = stage.get_node("gf_pos").position
	
	gf.global_position = stage.get_node("gf_pos").position
	bf.global_position = stage.get_node("bf_pos").position
	
	# because this can error out sometimes???
	if dad.flip() != null:
		dad.flip()
	
	characters.add_child(gf)
	characters.add_child(dad)
	characters.add_child(bf)
	
	if Gameplay.SONG.song.notes[cur_section].mustHitSection:
		focus_on("bf")
	else:
		focus_on("dad")
		
func load_notes():
	for section in Gameplay.SONG.song["notes"]:
		for note in section["sectionNotes"]:
			if note[1] != -1:
				if len(note) == 3:
					note.push_back(0)
				
				if note[3] is Array:
					note[3] = note[3][0]
				
				noteDataArray.push_back([float(note[0]) + (Options.get_data("note-offset") + (AudioServer.get_output_latency() * 1000) * Gameplay.song_multiplier), note[1], note[2], bool(section["mustHitSection"]), int(note[3])])
				
	speed = Gameplay.SONG.song.speed
	
	if Options.get_data("scroll-speed") > 0:
		match Options.get_data("scroll-type").to_lower():
			"multiplicative":
				speed *= Options.get_data("scroll-speed")
			"constant":
				speed = Options.get_data("scroll-speed")
	
	speed /= Gameplay.song_multiplier
	
	Gameplay.scroll_speed = speed
	
func position_strums():
	opponent_strums.global_position = Vector2(0, 610)
	player_strums.global_position = Vector2(ScreenRes.screen_width / 2, 610)
	
	opponent_strums.global_position.x += 150
	player_strums.global_position.x += 150
	
var old_countdown = -1
var countdown = 4

var countdown_tween = Tween.new()

func countdown_shit(fard):
	if fard == countdown:
		countdown -= 1
	
		match countdown:
			3:
				AudioHandler.play_countdown(countdown)
			2:
				AudioHandler.play_countdown(countdown)
				
				var sprite = load(Paths.scene("Gameplay/Ready")).instance()
				cam_hud.add_child(sprite)
				
				countdown_tween.interpolate_property(sprite, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), (Conductor.timeBetweenBeats / 1000), Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
				add_child(countdown_tween)
				countdown_tween.start()
			1:
				AudioHandler.play_countdown(countdown)
				
				var sprite = load(Paths.scene("Gameplay/Set")).instance()
				cam_hud.add_child(sprite)
				
				countdown_tween.interpolate_property(sprite, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), (Conductor.timeBetweenBeats / 1000), Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
				add_child(countdown_tween)
				countdown_tween.start()
			0:
				AudioHandler.play_countdown(countdown)
				
				var sprite = load(Paths.scene("Gameplay/Go")).instance()
				cam_hud.add_child(sprite)
				
				countdown_tween.interpolate_property(sprite, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), (Conductor.timeBetweenBeats / 1000), Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
				add_child(countdown_tween)
				countdown_tween.start()
			-1:
				countdown_active = false
				
				Conductor.songPosition = 0
				AudioHandler.play_inst(Gameplay.SONG.song.song)
				AudioHandler.play_voices(Gameplay.SONG.song.song)
				
				inst_length = AudioHandler.get_node("Inst").stream.get_length() * 1000.0
				
				timebar_tween.interpolate_property(cam_hud.get_node("TimeBar"), "modulate", $camHUD/TimeBar.modulate, Color(1, 1, 1, 1), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
				add_child(timebar_tween)
				timebar_tween.start()

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
			if(song_score > SongHighscore.get_score(Gameplay.SONG.song.song.to_lower().replace(" ", "-") + "-" + Gameplay.difficulty)):
				SongHighscore.set_score(Gameplay.SONG.song.song.to_lower().replace(" ", "-") + "-" + Gameplay.difficulty, song_score)
				SongAccuracy.set_acc(Gameplay.SONG.song.song.to_lower().replace(" ", "-") + "-" + Gameplay.difficulty, Util.round_decimal(song_accuracy * 100, 2))
				
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
	
func _physics_process(delta):
	if AudioHandler.get_node("Inst").playing:
		inst_time = AudioHandler.get_node("Inst").get_playback_position() * 1000.0
		
	if AudioHandler.get_node("Voices").playing:
		voices_time = AudioHandler.get_node("Voices").get_playback_position() * 1000.0
		
	if not countdown_active:
		cam_hud.get_node("TimeBar/TimeText").text = Util.format_time((inst_time / 1000) / Gameplay.song_multiplier, false) + " / " + Util.format_time((inst_length / 1000) / Gameplay.song_multiplier, false)
		cam_hud.get_node("TimeBar/FGColor").rect_scale.x = (inst_time / inst_length)
		
		if Conductor.songPosition >= inst_length:
			check_for_achievements()
		
	var index = 0
	for note in noteDataArray:
		if float(note[0]) > Conductor.songPosition + 5000:
			break
			
		if float(note[0]) - Conductor.songPosition < (1500 * Gameplay.song_multiplier):
			var dunceNote:Node2D = load("res://Scenes/Notes/Default/Note.tscn").instance()
			dunceNote.strumTime = note[0]
			dunceNote.noteData = int(note[1]) % Gameplay.key_count
			dunceNote.sustainLength = note[2]
			
			if dunceNote.sustainLength <= 50:
				dunceNote.sustainLength = 0
			
			dunceNote.mustPress = true
			
			dunceNote.set_direction()
			
			if note[3] and int(note[1]) % (Gameplay.key_count * 2) >= Gameplay.key_count:
				dunceNote.mustPress = false
			elif !note[3] and int(note[1]) % (Gameplay.key_count * 2) <= Gameplay.key_count - 1:
				dunceNote.mustPress = false
				
			if not dunceNote.mustPress:
				dunceNote.scale = opponent_strums.scale
			else:
				dunceNote.scale = player_strums.scale
				
			dunceNote.get_node("Line2D").texture = load("res://Assets/Images/UI Skins/" + Gameplay.ui_Skin + "/Sustains/" + dunceNote.dir_string + " hold0000.png")
			dunceNote.get_node("End").texture = load("res://Assets/Images/UI Skins/" + Gameplay.ui_Skin + "/Sustains/" + dunceNote.dir_string + " tail0000.png")
			
			game_notes.add_child(dunceNote)
			
			if dunceNote.mustPress:
				dunceNote.global_position.x = player_strums.get_children()[int(note[1]) % Gameplay.key_count].global_position.x
			else:
				dunceNote.global_position.x = opponent_strums.get_children()[int(note[1]) % Gameplay.key_count].global_position.x
				
			noteDataArray.remove(index)
	
		index += 1
		
var botplay_text_sine = 0.0
	
func _process(delta):
	sing_anims = sing_anims_list[Gameplay.key_count - 1]
	
	if not in_cutscene and not ending_song:
		if not countdown_active:
			Conductor.songPosition += (delta * 1000) * Gameplay.song_multiplier
		else:
			Conductor.songPosition += (delta * 1000)
		
	if Input.is_action_just_pressed("chart_editor"):		
		$Misc/Transition.transition_to_scene("ChartEditor")
		
	if Input.is_action_just_pressed("reset") and Options.get_data("enable-retry-button"):
		health -= 999999999
	
	$camHUD/BotplayText.visible = Options.get_data("botplay")
	
	botplay_text_sine += 180 * delta
	$camHUD/BotplayText.modulate.a = 1 - sin((PI * botplay_text_sine) / 180)
	
	if $camHUD/BotplayText.modulate.a > 1:
		$camHUD/BotplayText.modulate.a = 1
		
	if countdown_active:
		if Conductor.songPosition >= Conductor.timeBetweenBeats * -4:
			countdown_shit(4)
			
		if Conductor.songPosition >= Conductor.timeBetweenBeats * -3:
			countdown_shit(3)
			
		if Conductor.songPosition >= Conductor.timeBetweenBeats * -2:
			countdown_shit(2)
			
		if Conductor.songPosition >= Conductor.timeBetweenBeats * -1:
			countdown_shit(1)
			
		if Conductor.songPosition >= 0:
			countdown_shit(0)
		
	icon_p2.scale = lerp(icon_p2.scale, Vector2.ONE, delta * 15)
	icon_p1.scale = lerp(icon_p1.scale, Vector2.ONE, delta * 15)
	
	icon_p2.position.x = ((589 + health_bar.position.x) - ((icon_p2.scale.x - 1) * 70)) - ((health - 1) * 589 / 2)
	icon_p1.position.x = ((701 + health_bar.position.x) + ((icon_p1.scale.x - 1) * 70)) - ((health - 1) * 589 / 2)
	
	health_bar.get_node("BFColor").rect_scale.x = health / 2
	
	if cam_zooming:
		set_game_zoom(lerp(cam_game.zoom.x, default_cam_zoom, delta * 7), lerp(cam_game.zoom.y, default_cam_zoom, delta * 7))
		set_hud_zoom(lerp(cam_hud.scale.x, 1, delta * 7), lerp(cam_hud.scale.y, 1, delta * 7))
	
	if Input.is_action_just_pressed("ui_back"):
		$Misc/Transition.transition_to_scene("FreeplayMenu")
		
	for note in game_notes.get_children():
		var strum
		if note.mustPress:
			strum = player_strums.get_children()[note.noteData % Gameplay.key_count]
		else:
			strum = opponent_strums.get_children()[note.noteData % Gameplay.key_count]
			
		note.global_position.x = strum.global_position.x
			
		if downscroll:
			note.global_position.y = strum.global_position.y + (0.45 * (Conductor.songPosition - note.strumTime) * Util.round_decimal(speed, 2))
		else:
			note.global_position.y = strum.global_position.y + (-0.45 * (Conductor.songPosition - note.strumTime) * Util.round_decimal(speed, 2))
			
		# opponent notes
		if not note.mustPress:
			if not countdown_active:
				if Conductor.songPosition >= note.strumTime:
					cam_zooming = true
					
					if dad.special_anim != true:
						dad.hold_timer = 0
						dad.play_anim(sing_anims[note.noteData % Gameplay.key_count], true)
						
					for modchart in loaded_modcharts:
						if modchart.opponent_note_hit(note.noteData % Gameplay.key_count) != null:
							modchart.opponent_note_hit(note.noteData % Gameplay.key_count)
					
					AudioHandler.get_node("Voices").volume_db = 0
					
					if Options.get_data("strum-animations"):
						strum.play_anim("confirm")
						
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
		var your2 = (note.mustPress and note.sustainLength >= 0 and not pressed[note.noteData % Gameplay.key_count] and not Options.get_data("botplay"))
		
		if note.beingPressed and note.sustainLength <= sustainMissRange:
			note.sustainLength -= (delta * 1000) * Gameplay.song_multiplier
			note.global_position.y = player_strums.get_children()[note.noteData % Gameplay.key_count].global_position.y
			
			if note.sustainLength <= 0:
				note.queue_free()
		else:
			if your or your2:
				if Conductor.songPosition > note.strumTime + Conductor.safeZoneOffset:
					song_score -= 10
					song_misses += 1
					combo = 0
					
					if note.sustainLength >= 150:
						health -= 0.2475
					else:
						health -= 0.0475
						
					AudioHandler.play_audio("missnote" + str(randi()%3 + 1))
					
					total_notes_hit += 1
					calculate_accuracy()
					
					if bf.special_anim != true:
						bf.play_anim(sing_anims[note.noteData % Gameplay.key_count] + "miss", true)
					
					AudioHandler.get_node("Voices").volume_db = -999
					note.queue_free()
					
	process_inputs(delta)
					
	if health < 0:
		health = 0
		SceneManager.switch_scene("Gameover")
		
	if health > 2:
		health = 2
		
var old_keycount = -1
		
var just_pressed = []
var pressed = []
var released = []

var note_data_possibles = []
var rythm_array = []
var note_data_times = []

var dont_hit = []

var cur_rating = "marvelous"

func calculate_accuracy():
	if total_notes_hit != 0 and hits != 0:
		song_accuracy = min(1, max(0, (hits / total_notes_hit)))
	else:
		song_accuracy = 0
		
	cam_hud.get_node("RatingText").text = "Marvelous: " + str(marvelous)
	cam_hud.get_node("RatingText").text += "\nSicks: " + str(sicks)
	cam_hud.get_node("RatingText").text += "\nGoods: " + str(goods)
	cam_hud.get_node("RatingText").text += "\nBads: " + str(bads)
	cam_hud.get_node("RatingText").text += "\nShits: " + str(shits)
	cam_hud.get_node("RatingText").text += "\nMisses: " + str(song_misses)
	
	health_bar.get_node("ScoreText").bbcode_text = "[center]Score: " + str(song_score) + " // Misses: " + str(song_misses) + " // Accuracy: " + str(Util.round_decimal(song_accuracy * 100, 2)) + "%"
		
func process_inputs(delta):
	if old_keycount != Gameplay.key_count:
		old_keycount = Gameplay.key_count
		
		just_pressed = []
		pressed = []
		released = []
		
		for i in Gameplay.key_count:
			just_pressed.append(false)
			pressed.append(false)
			released.append(false)
			
	for strum in opponent_strums.get_children():
		if strum.anim_finished:
			strum.play_anim("static")
			
	for i in len(just_pressed):
		just_pressed[i] = Input.is_action_just_pressed("gameplay_" + str(i))
		pressed[i] = Input.is_action_pressed("gameplay_" + str(i))
		released[i] = Input.is_action_just_released("gameplay_" + str(i))
		
		if just_pressed[i]:
			player_strums.get_child(i).play_anim("press")
			
		if released[i]:
			player_strums.get_child(i).play_anim("static")
			
	if just_pressed.has(true):
		var possible_notes = []
		
		note_data_possibles = []
		rythm_array = []
		note_data_times = []
		dont_hit = []
		
		for i in Gameplay.key_count:
			note_data_possibles.append(false)
			note_data_times.append(-1)

			rythm_array.append(false)
			
			dont_hit.append(false)
		
		for note in game_notes.get_children():
			note.calculate_can_be_hit()
			
			if note.canBeHit and note.mustPress and !note.tooLate:
				possible_notes.append(note)
				
		possible_notes.sort_custom(self, "sort_ascending")
	
		if len(possible_notes) > 0:
			for i in len(possible_notes):
				var real_note = possible_notes[i]
				if real_note.sustainLength <= 0:
					if just_pressed[real_note.noteData] and not note_data_possibles[real_note.noteData]:
						note_data_possibles[real_note.noteData] = true
						note_data_times[real_note.noteData] = real_note.strumTime
						
						bf.hold_timer = 0
						
						good_note_hit(real_note)
						
						if dont_hit.has(real_note):
							note_miss(real_note.noteData)
							rythm_array[i] = true
							
					if real_note.strumTime == note_data_times[real_note.noteData]:
						good_note_hit(real_note)
				else:
					if pressed[real_note.noteData] and not note_data_possibles[real_note.noteData]:
						if just_pressed[real_note.noteData]:
							pop_up_score(real_note.strumTime, real_note)
							
						real_note.beingPressed = true
						note_data_possibles[real_note.noteData] = true
						note_data_times[real_note.noteData] = real_note.strumTime
						
						bf.hold_timer = 0
		
		if not Options.get_data("ghost-tapping"):
			for i in len(just_pressed):
				if just_pressed[i] and not note_data_possibles[i] and not rythm_array[i]:
					note_miss(i)
					
	if bf.hold_timer > Conductor.timeBetweenSteps * bf.sing_duration * 0.001 and not pressed.has(true):
		if bf.last_anim.begins_with('sing') and not bf.last_anim.ends_with('miss'):
			bf.dance()
			
	for note in game_notes.get_children():
		if note.mustPress and note.sustainLength > 0 and pressed[note.noteData] and Conductor.songPosition >= note.strumTime or Options.get_data("botplay") and note.mustPress and note.sustainLength > 0 and Conductor.songPosition >= note.strumTime:
			var strum = player_strums.get_children()[note.noteData]
			
			if Options.get_data("strum-animations"):
				strum.play_anim("confirm")
			
			if bf.special_anim != true:
				bf.play_anim(sing_anims[note.noteData], true)
				
			for modchart in loaded_modcharts:
				if modchart.player_note_hit(note.noteData) != null:
					modchart.player_note_hit(note.noteData)
			
			AudioHandler.get_node("Voices").volume_db = 0
			
			if Options.get_data("pussy-mode"):
				health += delta / 4
			
			note.get_node("Note").visible = false
			note.global_position.y = strum.global_position.y
			note.sustainLength -= (delta * 1000) * Gameplay.song_multiplier
			if note.sustainLength <= 0:
				note.queue_free()
						
func note_miss(direction = 0):
	health -= 0.0475
	
	song_misses += 1
	AudioHandler.get_node("Voices").volume_db = -999
	
	if combo > 5:
		gf.play_anim("sad")
		
	combo = 0
	song_score -= 10
	
	total_notes_hit += 1
	calculate_accuracy()
	
	var miss_audio = "missnote" + str(randi()%3 + 1)
	AudioHandler.play_audio(miss_audio)
	
	bf.play_anim(sing_anims[direction] + " miss", true)
		
func sort_ascending(a, b):
	if a.strumTime < b.strumTime:
		return true
		
	return false
	
func pop_up_score(strum_time, note):
	var note_ms = (Conductor.songPosition - strum_time) / Gameplay.song_multiplier

	var rating_scores = [350, 200, 100, 50]
	
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
				note_splash.noteData = note.noteData
				note_splash.global_position = player_strums.get_children()[note.noteData].global_position
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
				health -= 0.1
				
	for rating_spr in $camHUD/Ratings.get_children():
		rating_spr.get_node("MS").visible = false

	$camHUD/Ratings.add_child(rating)
	
func good_note_hit(note):
	if not note.wasGoodHit:
		pop_up_score(note.strumTime, note)
		combo += 1
		hits += 1
		
		health += 0.023
		
		bf.play_anim(sing_anims[note.noteData], true)
		
		player_strums.get_child(note.noteData).play_anim("confirm")
		
		note.wasGoodHit = true
		AudioHandler.get_node("Voices").volume_db = 0
		
		calculate_accuracy()
		
		note.queue_free()
			
func set_game_zoom(x, y = null):
	var zoom_x = x
	var zoom_y = 0
	
	if y != null:
		zoom_y = y
	else:
		zoom_y = x
		
	cam_game.zoom = Vector2(zoom_x, zoom_y)
	
func set_hud_zoom(x, y = null):
	var zoom_x = x
	var zoom_y = 0
	
	if y != null:
		zoom_y = y
	else:
		zoom_y = x
		
	cam_hud.scale = Vector2(zoom_x, zoom_y)
	cam_hud.offset.x = 0 - ((zoom_x - 1) * ScreenRes.screen_width / 2)
	cam_hud.offset.y = 0 - ((zoom_y - 1) * ScreenRes.screen_height / 2)
			
func beat_hit():
	if not countdown_active:
		icon_p2.scale = Vector2(1.2, 1.2)
		icon_p1.scale = Vector2(1.2, 1.2)
	
	if bf != null:
		if bf.is_dancing() or bf.last_anim.ends_with("miss") or bf.last_anim == "hey" or bf.last_anim == "scared":
			bf.dance()
			
	if dad != null:
		if dad.is_dancing() or (Gameplay.SONG.song.player2 == gf_version and dad.last_anim == "cheer" or dad.last_anim == "scared"):
			dad.dance()
			
	if gf != null:
		if (gf.is_dancing() or gf.last_anim == "cheer" or gf.last_anim == "scared" or (gf.last_anim == "hairFall" and gf.get_node("anim").current_animation == "")) and dad != gf:
			gf.dance()
	
	if cam_zooming:
		if Conductor.curBeat % 4 == 0:
			set_game_zoom(default_cam_zoom - 0.015)
			set_hud_zoom(1.035)
		
func focus_on(character):
	match character:
		"gf", "girlfriend":
			var gorl = gf.global_position + gf.get_node("camera_pos").position
			cam_game.position = Vector2(gorl.x, gorl.y)
		"bf", "boyfriend":
			var boy = bf.global_position + bf.get_node("camera_pos").position
			cam_game.position = Vector2(boy.x, boy.y)
		_:
			var father = dad.global_position + dad.get_node("camera_pos").position
			
			if dad.is_player:
				father.x = dad.global_position.x + (dad.get_node("camera_pos").position.x + 250)
				
			cam_game.position = Vector2(father.x, father.y)

func step_hit():
	if not countdown_active:
		var gaming = 20
		
		if OS.get_name() == "Windows":
			gaming = 30
		
		if Gameplay.song_multiplier >= 1:
			gaming *= Gameplay.song_multiplier
		
		if not ending_song and abs(inst_time + (AudioServer.get_time_since_last_mix() * 1000) - (Conductor.songPosition)) > gaming || (Gameplay.SONG.song.needsVoices && abs(voices_time + (AudioServer.get_time_since_last_mix() * 1000) - (Conductor.songPosition)) > gaming):
			resync_vocals()
			
	var prevSection = cur_section
	
	cur_section = floor(Conductor.curStep / 16)
	
	if cur_section < 0:
		cur_section = 0
		
	if cur_section > len(Gameplay.SONG.song.notes) - 1:
		cur_section = len(Gameplay.SONG.song.notes) - 1
		
	if Gameplay.SONG.song["notes"][cur_section]["mustHitSection"]:
		focus_on("bf")
		$camHUD/TimeBar/FGColor.color = bf.health_color
	else:
		focus_on("dad")
		$camHUD/TimeBar/FGColor.color = dad.health_color
		
func resync_vocals():
	Conductor.songPosition = (AudioHandler.get_node("Inst").get_playback_position() * 1000)
	AudioHandler.get_node("Voices").seek(Conductor.songPosition / 1000)
	
func tween_arrows_in():
	var i = 0
	for strum in opponent_strums.get_children():
		strum.modulate.a = 0
		strum.position.y -= 10
		
		cam_hud.get_node("StrumTween").interpolate_property(strum, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1, Tween.TRANS_CIRC, Tween.EASE_OUT, 0.5 + (0.2 * i))
		cam_hud.get_node("StrumTween").interpolate_property(strum, "position", strum.position, Vector2(strum.position.x, strum.position.y + 10), 1, Tween.TRANS_CIRC, Tween.EASE_OUT, 0.5 + (0.2 * i))
		
		i += 1
		
	var i2 = 0
	for strum in player_strums.get_children():
		strum.modulate.a = 0
		strum.position.y -= 10
		
		cam_hud.get_node("StrumTween").interpolate_property(strum, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1, Tween.TRANS_CIRC, Tween.EASE_OUT, 0.5 + (0.2 * i2))
		cam_hud.get_node("StrumTween").interpolate_property(strum, "position", strum.position, Vector2(strum.position.x, strum.position.y + 10), 1, Tween.TRANS_CIRC, Tween.EASE_OUT, 0.5 + (0.2 * i2))
		
		i2 += 1
		
	cam_hud.get_node("StrumTween").start()
