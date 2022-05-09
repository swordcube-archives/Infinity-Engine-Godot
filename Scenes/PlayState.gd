extends Node2D

onready var note_splash_template = $CanvasLayer/HUD/NoteSplashTemplate

onready var camera = $Camera2D
onready var hud = $CanvasLayer/HUD
onready var ratingtext = $CanvasLayer/HUD/RatingText
onready var ratings = $CanvasLayer/HUD/Ratings

onready var health_bar = $CanvasLayer/HUD/HealthBar

onready var dad_health_bar = $CanvasLayer/HUD/HealthBar/Color1
onready var bf_health_bar = $CanvasLayer/HUD/HealthBar/Color2

onready var iconP2 = $CanvasLayer/HUD/HealthBar/IconP2
onready var iconP1 = $CanvasLayer/HUD/HealthBar/IconP1

onready var timebar = $CanvasLayer/HUD/TimeBar
onready var timebar_progress = $CanvasLayer/HUD/TimeBar/Color1
onready var timebar_text = $CanvasLayer/HUD/TimeBar/Label

onready var opponent_strums:Node2D = null
onready var player_strums:Node2D = null
onready var notes:Node2D = $CanvasLayer/HUD/Notes

onready var downscroll:bool = Options.get_data("downscroll")
onready var middlescroll:bool = Options.get_data("middlescroll")
onready var botplay:bool = Options.get_data("botplay")
onready var note_splashes:bool = Options.get_data("note-splashes")

var ending_song:bool = false

var rating_template:Node2D = load("res://Scenes/PlayState/Rating.tscn").instance()

var countdown_active:bool = true
var SONG:Dictionary = GameplaySettings.SONG.song

var stage:Node2D
var dad:Node2D
var gf:Node2D
var bf:Node2D

var sing_anims:Array = ["singLEFT", "singDOWN", "singUP", "singRIGHT"]

var cam_zooming:bool = false

var noteDataArray:Array = []

var just_pressed:Array = []
var pressed:Array = []
var just_released:Array = []
var released:Array = []

var note_data_possibles:Array = []
var rythm_array:Array = []
var note_data_times:Array = []
var dont_hit:Array = []

var rating_textures:Array = []
var combo_textures:Array = []

var default_cam_zoom:float = 1.0

var marvelous:int = 0
var sicks:int = 0
var goods:int = 0
var bads:int = 0
var shits:int = 0

var rating1:String = "N/A"
var rating2:String = "?"

var song_score:int = 0
var song_misses:int = 0
var song_accuracy:float = 0

var combo:int = 0
var total_notes:int = 0
var total_hit:float = 0.0

var health:float = 1.0

func refresh_combo_textures():
	rating_textures = [
		GameplaySettings.ui_skin.marvelous_tex,
		GameplaySettings.ui_skin.sick_tex,
		GameplaySettings.ui_skin.good_tex,
		GameplaySettings.ui_skin.bad_tex,
		GameplaySettings.ui_skin.shit_tex,
	]
	
	combo_textures = [
		load(GameplaySettings.ui_skin.combo_num_path + "0.png"),
		load(GameplaySettings.ui_skin.combo_num_path + "1.png"),
		load(GameplaySettings.ui_skin.combo_num_path + "2.png"),
		load(GameplaySettings.ui_skin.combo_num_path + "3.png"),
		load(GameplaySettings.ui_skin.combo_num_path + "4.png"),
		load(GameplaySettings.ui_skin.combo_num_path + "5.png"),
		load(GameplaySettings.ui_skin.combo_num_path + "6.png"),
		load(GameplaySettings.ui_skin.combo_num_path + "7.png"),
		load(GameplaySettings.ui_skin.combo_num_path + "8.png"),
		load(GameplaySettings.ui_skin.combo_num_path + "9.png")
	]

func _ready():	
	Keybinds.setup_Binds()	
	
	GameplaySettings.load_ui_skin()
	refresh_combo_textures()
	
	if not Options.get_data("optimization"):
		load_stage_and_characters()
		reload_healthbar()
		
	if botplay:
		GameplaySettings.used_practice = true
	
	opponent_strums = load("res://Scenes/Strums/" + str(GameplaySettings.key_count) + "Key.tscn").instance()
	player_strums = load("res://Scenes/Strums/" + str(GameplaySettings.key_count) + "Key.tscn").instance()
	
	var arrow_move = 320
	opponent_strums.global_position.x = arrow_move
	player_strums.global_position.x = arrow_move + (CoolUtil.screen_res.x / 2)
	
	if middlescroll:
		opponent_strums.global_position.x -= 9999
		player_strums.global_position.x = 640
	
	var strum_y = 100
	if downscroll:
		strum_y = 625
		health_bar.global_position.y = 70
		timebar.global_position.y = 700
		
	opponent_strums.global_position.y = strum_y
	player_strums.global_position.y = strum_y
	
	hud.add_child(opponent_strums)
	hud.add_child(player_strums)
	
	hud.move_child(opponent_strums, 0)
	hud.move_child(player_strums, 0)
		
	Conductor.change_bpm(SONG["bpm"])
	Conductor.recalculate_values()
	Conductor.connect("beat_hit", self, "beat_hit")
	Conductor.connect("step_hit", self, "step_hit")
	
	Conductor.song_position = Conductor.crochet * -5
	
	for section in SONG["notes"]:
		for note in section["sectionNotes"]:
			if note[1] != -1:
				if len(note) == 3:
					note.push_back(0)
				
				var type:String = "Default"
				
				if note[3] is Array:
					note[3] = note[3][0]
				elif note[3] is String:
					type = note[3]
					
					note[3] = 0
					note.push_back(type)
				
				if len(note) == 4:
					note.push_back("Default")
				
				if note[4]:
					if note[4] is String:
						type = note[4]
				
				if not "altAnim" in section:
					section["altAnim"] = false
				
				noteDataArray.push_back([float(note[0]) + Options.get_data("note-offset") + (AudioServer.get_output_latency() * 1000), note[1], note[2], bool(section["mustHitSection"]), int(note[3]), type, bool(section["altAnim"])])
	
	#print(noteDataArray[0])
	
	GameplaySettings.scroll_speed = SONG.speed
	
	if Options.get_data("scroll-speed") > 0:
		match Options.get_data("scroll-type"):
			"multiplicative":
				GameplaySettings.scroll_speed *= Options.get_data("scroll-speed")
			"constant":
				GameplaySettings.scroll_speed = Options.get_data("scroll-speed")
				
	GameplaySettings.scroll_speed /= GameplaySettings.song_multiplier
	
	focus_camera()
	
	var zoomThing = 1
	if stage:
		zoomThing = 1 - stage.default_cam_zoom
		
	var goodZoom = 1 + zoomThing
	
	camera.zoom = Vector2(goodZoom, goodZoom)
	default_cam_zoom = goodZoom
	
var cur_stage = "stage"
var gf_version = "gf"
	
func load_stage_and_characters():
	if "stage" in SONG:
		cur_stage = SONG["stage"]
	else:
		match SONG.song.to_lower():
			"spookeez", "south", "monster":
				cur_stage = "spooky"
			"pico", "philly nice", "blammed":
				cur_stage = "philly"
			"satin panties", "high", "m.i.l.f":
				cur_stage = "limo"
			"cocoa", "eggnog":
				cur_stage = "mall"
			"winter horrorland":
				cur_stage = "mallEvil"
			"senpai", "roses":
				cur_stage = "school"
			"thorns":
				cur_stage = "schoolEvil"
			_:
				cur_stage = "stage"
				
	if ResourceLoader.exists(Paths.stage(cur_stage)):
		print(Paths.stage(cur_stage) + " EXISTS!!!")
		
		stage = load(Paths.stage(cur_stage)).instance()
		add_child(stage)
	else:
		print(Paths.stage(cur_stage) + " DOESN'T EXIST!!!")
		
		cur_stage = "stage"
		stage = load(Paths.stage(cur_stage)).instance()
		
	if "gf" in SONG:
		gf_version = SONG["gf"]
	elif "gfVersion" in SONG:
		gf_version = SONG["gfVersion"]
	elif "player3" in SONG:
		gf_version = SONG["player3"]
	else:
		match SONG.song.to_lower():
			"cocoa", "eggnog", "winter horrorland":
				gf_version = "gf-christmas"
			"senpai", "roses", "thorns":
				gf_version = "gf-pixel"
			_:
				gf_version = "gf"
				
	# load gf
	if ResourceLoader.exists(Paths.character(gf_version)):
		gf = load(Paths.character(gf_version)).instance()
	else:
		gf = load(Paths.character("gf")).instance()
		
	gf.global_position = stage.gf_pos
		
	# load dad
	if ResourceLoader.exists(Paths.character(SONG.player2)):
		dad = load(Paths.character(SONG.player2)).instance()
		
		if dad.is_player:
			dad.scale.x *= -1
	else:
		dad = load(Paths.character("bf")).instance()
		
		if dad.is_player:
			dad.scale.x *= -1
		
	dad.global_position = stage.dad_pos
		
	# load bf
	if ResourceLoader.exists(Paths.character(SONG.player1)):
		bf = load(Paths.character(SONG.player1)).instance()
	else:
		bf = load(Paths.character("bf")).instance()
		
	bf.global_position = stage.bf_pos
	
	add_child(stage)
	add_child(gf)
	add_child(dad)
	add_child(bf)
	
func _physics_process(delta):
	iconP2.scale = lerp(iconP2.scale, Vector2.ONE, delta * 20)
	iconP1.scale = lerp(iconP1.scale, Vector2.ONE, delta * 20)
	
	if cam_zooming:
		camera.zoom = Vector2(lerp(camera.zoom.x, default_cam_zoom, delta * 7), lerp(camera.zoom.y, default_cam_zoom, delta * 7))
		
		if camera.zoom.x < 0.65:
			camera.zoom = Vector2(0.65, 0.65)
		
		hud.scale = lerp(hud.scale, Vector2.ONE, delta * 7)
		hud.position.x = (hud.scale.x - 1) * -640
		hud.position.y = (hud.scale.y - 1) * -360
	
	if not farded and Conductor.song_position >= Conductor.crochet * -4:
		start_countdown()
		
	if not countdown_active:
		var a = (Conductor.song_position / 1000.0) / GameplaySettings.song_multiplier
		var b = (AudioHandler.inst.stream.get_length()) / GameplaySettings.song_multiplier
		var cur_time:String = CoolUtil.format_time(a)
		var length:String = CoolUtil.format_time(b)
		timebar_progress.rect_scale.x = a / b
		if timebar_progress.rect_scale.x > 1:
			timebar_progress.rect_scale.x = 1
		timebar_text.text = cur_time + " / " + length
		
		if a > b:
			if not ending_song:
				end_song()
		
	for strum in opponent_strums.get_children():
		if strum.anim_finished:
			strum.play_anim("static")
		
	var index = 0
	# yes, i did take this note spawning code from
	# LE godot lol
	for note in noteDataArray:
		if float(note[0]) > Conductor.song_position + (5000 * GameplaySettings.song_multiplier):
			break
		
		if float(note[0]) - Conductor.song_position < (2500 * GameplaySettings.song_multiplier):
			var new_note = GameplaySettings.note_types[note[5]].duplicate()
			new_note.note_type = note[5]
			new_note.strum_time = float(note[0])
			
			new_note.note_data = int(note[1]) % GameplaySettings.key_count
			
			if "is_alt" in new_note:
				new_note.is_alt = note[6]
			
			if int(note[4]) != null:
				if "character" in new_note:
					new_note.character = note[4]
					
			if float(note[2]) >= Conductor.step_crochet:
				new_note.og_sustain_length = float(note[2]) - 50
				new_note.sustain_length = float(note[2]) - 50
				new_note.get_node("End").visible = true
				new_note.get_node("Line2D").visible = true
			
			var must_press = true
			
			if note[3] and int(note[1]) % (GameplaySettings.key_count * 2) >= GameplaySettings.key_count:
				must_press = false
			elif !note[3] and int(note[1]) % (GameplaySettings.key_count * 2) <= GameplaySettings.key_count - 1:
				must_press = false
				
			if must_press:
				new_note.direction = player_strums.get_child(new_note.note_data).direction
				new_note.play_anim("")
			else:
				new_note.direction = opponent_strums.get_child(new_note.note_data).direction
				new_note.play_anim("")
				
			new_note.load_sus_texture()
			
			new_note.must_press = must_press
			#new_note.global_position.y = -5000
			
			notes.add_child(new_note)
					
			noteDataArray.remove(index)
					
		index += 1
	
var countdown:int = 5
var farded:bool = false

onready var countdown_timer:Timer = $CanvasLayer/HUD/CountdownTimer

func end_song():
	ending_song = true
	
	var song = SONG.song + "-" + GameplaySettings.difficulty
	
	if not GameplaySettings.used_practice and not Options.get_data("pussy-mode") and GameplaySettings.song_multiplier >= 1:
		if song_score > Highscores.get_song_score(song):
			Highscores.set_song_score(song, song_score)
			
	if GameplaySettings.story_mode:
		GameplaySettings.story_playlist.remove(0)
		
		if not GameplaySettings.used_practice and not Options.get_data("pussy-mode") and GameplaySettings.song_multiplier >= 1:
			GameplaySettings.story_score += song_score
			
		if GameplaySettings.story_playlist.size() > 0:
			var songName = SONG.song
			GameplaySettings.SONG = CoolUtil.get_json(Paths.song_json(songName, GameplaySettings.difficulty))
			get_tree().reload_current_scene()
		else:
			if GameplaySettings.song_multiplier >= 1:
				if GameplaySettings.story_score > Highscores.get_week_score(GameplaySettings.week_name):
					Highscores.set_week_score(GameplaySettings.week_name, GameplaySettings.story_score)
			
			AudioHandler.play_audio("freakyMenu")
			SceneHandler.switch_to("StoryMenu")
	else:
		AudioHandler.stop_music()
		AudioHandler.play_music("freakyMenu")			
		SceneHandler.switch_to("FreeplayMenu")
	
	AudioHandler.inst.stop()
	AudioHandler.voices.stop()

func start_countdown():
	farded = true
	countdown_tick()
	for i in 4:
		countdown_timer.stop()
		countdown_timer.wait_time = Conductor.crochet / 1000.0
		countdown_timer.start()
		yield(countdown_timer, "timeout")
		countdown_tick()
		
onready var countdown_tween = $CanvasLayer/HUD/Tween
onready var countdown_sprite = $CanvasLayer/HUD/Countdown

onready var countdown_sounds = [
	$CanvasLayer/HUD/Countdown3,
	$CanvasLayer/HUD/Countdown2,
	$CanvasLayer/HUD/Countdown1,
	$CanvasLayer/HUD/CountdownGo
]
	
func countdown_tick():
	countdown -= 1
	#print("COUNTDOWN: " + str(countdown))
	match countdown:
		4:
			var sound = countdown_sounds[0]
			sound.stream = GameplaySettings.ui_skin.countdown_3
			sound.play()
		3:
			var sound = countdown_sounds[1]
			sound.stream = GameplaySettings.ui_skin.countdown_2
			sound.play()
			countdown_sprite.texture = GameplaySettings.ui_skin.ready_tex
			countdown_sprite.modulate.a = 1
			countdown_tween.stop_all()
			countdown_tween.interpolate_property(countdown_sprite, "modulate", countdown_sprite.modulate, Color(1, 1, 1, 0), Conductor.crochet / 1000, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			countdown_tween.start()
		2:
			var sound = countdown_sounds[2]
			sound.stream = GameplaySettings.ui_skin.countdown_1
			sound.play()
			countdown_sprite.texture = GameplaySettings.ui_skin.set_tex
			countdown_sprite.modulate.a = 1
			countdown_tween.stop_all()
			countdown_tween.interpolate_property(countdown_sprite, "modulate", countdown_sprite.modulate, Color(1, 1, 1, 0), Conductor.crochet / 1000, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			countdown_tween.start()
		1:
			var sound = countdown_sounds[3]
			sound.stream = GameplaySettings.ui_skin.countdown_go
			sound.play()
			countdown_sprite.texture = GameplaySettings.ui_skin.go_tex
			countdown_sprite.modulate.a = 1
			countdown_tween.stop_all()
			countdown_tween.interpolate_property(countdown_sprite, "modulate", countdown_sprite.modulate, Color(1, 1, 1, 0), Conductor.crochet / 1000, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			countdown_tween.start()
		0:
			for sound in countdown_sounds:
				sound.queue_free()
				
			countdown_active = false
			
			AudioHandler.play_inst(SONG.song)
			AudioHandler.play_voices(SONG.song)
			
			AudioHandler.inst.seek(0)
			AudioHandler.voices.seek(0)
			
			Conductor.song_position = 0
			
			countdown_tween.stop_all()
			countdown_tween.interpolate_property(timebar, "modulate", timebar.modulate, Color(1, 1, 1, 1), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			countdown_tween.start()
			
var started_countdown:bool = true
		
func _process(delta):
	var display_health:float = health
	if display_health < 0:
		health = 0
	if display_health > 2:
		health = 2
		
	health_bar.color2.rect_scale.x = display_health
		
	iconP2.position.x = 21 - ((display_health - 1) * 295)
	iconP1.position.x = -19 - ((display_health - 1) * 295)
	
	var health_percentage:int = floor((display_health / 2) * 100)
	
	if health_percentage <= 20:
		iconP1.switch_to("losing")
		iconP2.switch_to("winning")
	elif health_percentage >= 80:
		iconP2.switch_to("losing")
		iconP1.switch_to("winning")
	else:
		iconP1.switch_to("normal")
		iconP2.switch_to("normal")
		
	if not GameplaySettings.practice_mode and health == 0:
		if bf:
			GameplaySettings.death_shit["character"] = bf.death_character
			GameplaySettings.death_shit["char_pos"] = bf.global_position
			GameplaySettings.death_shit["cam_pos"] = camera.position
		else:
			GameplaySettings.death_shit["character"] = "bf-dead"
			GameplaySettings.death_shit["char_pos"] = Vector2(700, 360)
			GameplaySettings.death_shit["cam_pos"] = Vector2(700, 360)
			
		SceneHandler.switch_to("DeathScreen", "", false)
		
	if Input.is_action_just_pressed("reset"):
		if Options.get_data("enable-insta-kill-button"):
			health -= 999999999
		
	if started_countdown:
		if countdown_active:
			Conductor.song_position += (delta * 1000)
		else:
			if not Transition.transitioning:
				Conductor.song_position += (delta * 1000) * GameplaySettings.song_multiplier
		
	if Input.is_action_just_pressed("ui_back"):
		ending_song = true
		AudioHandler.stop_music()
		AudioHandler.inst.stop()
		AudioHandler.voices.stop()
		AudioHandler.play_music("freakyMenu")
		SceneHandler.switch_to("FreeplayMenu")
		
	for note in notes.get_children():
		if note.must_press:
			note.scale = player_strums.scale
			note.global_position.x = player_strums.get_child(note.note_data).global_position.x
			note.global_position.y = player_strums.get_child(note.note_data).global_position.y
			
			if downscroll:
				note.global_position.y += (0.45 * (Conductor.song_position - note.strum_time)) * GameplaySettings.scroll_speed
			else:
				note.global_position.y -= (0.45 * (Conductor.song_position - note.strum_time)) * GameplaySettings.scroll_speed
		else:
			note.scale = opponent_strums.scale
			note.global_position.x = opponent_strums.get_child(note.note_data).global_position.x
			note.global_position.y = opponent_strums.get_child(note.note_data).global_position.y
			
			if downscroll:
				note.global_position.y += (0.45 * (Conductor.song_position - note.strum_time)) * GameplaySettings.scroll_speed
			else:
				note.global_position.y -= (0.45 * (Conductor.song_position - note.strum_time)) * GameplaySettings.scroll_speed
			
			if Conductor.song_position >= note.strum_time:
				cam_zooming = true
				note.spr.visible = false
				opponent_strums.get_child(note.note_data).play_anim("confirm")
				note.sustain_length -= (delta * 1000) * GameplaySettings.song_multiplier
				note.global_position.y = opponent_strums.get_child(note.note_data).global_position.y
				
				if dad:
					dad.hold_timer = 0
					dad.play_anim(sing_anims[note.note_data])
					
				AudioHandler.voices.volume_db = 0
				
				if note.sustain_length <= -50:
					note.line2d.points[1].y = 0
					note.queue_free()
					
	process_inputs(delta)
	
func process_inputs(delta):
	refresh_input_bullshit()
	
	for i in just_pressed.size():
		just_pressed[i] = Input.is_action_just_pressed("gameplay_" + str(i))
		pressed[i] = Input.is_action_pressed("gameplay_" + str(i))
		just_released[i] = Input.is_action_just_released("gameplay_" + str(i))
		released[i] = not Input.is_action_pressed("gameplay_" + str(i))
		
		if just_pressed[i]:
			player_strums.get_child(i).play_anim("press")
			
		if just_released[i]:
			player_strums.get_child(i).play_anim("static")
			
	if not botplay:
		if just_pressed.has(true):
			var possible_notes = []
			
			note_data_possibles = []
			rythm_array = []
			note_data_times = []
			dont_hit = []
			
			for i in GameplaySettings.key_count:
				note_data_possibles.append(false)
				note_data_times.append(-1)

				rythm_array.append(false)
				
				dont_hit.append(false)
			
			for note in notes.get_children():
				note.calculate_can_be_hit()
				
				if (note.can_be_hit and note.must_press and not note.too_late) or note.being_pressed:
					possible_notes.append(note)
					
			possible_notes.sort_custom(self, "sort_ascending")
			
			if len(possible_notes) > 0:
				for i in len(possible_notes):
					var real_note:Node2D = possible_notes[i]
					if real_note.sustain_length <= 0:
						if just_pressed[real_note.note_data] and not note_data_possibles[real_note.note_data]:
							note_data_possibles[real_note.note_data] = true
							note_data_times[real_note.note_data] = real_note.strum_time
							
							good_note_hit(real_note)
							
							if dont_hit.has(real_note):
								note_miss(real_note.note_data)
								rythm_array[i] = true
									
							if real_note.strum_time == note_data_times[real_note.note_data]:
								good_note_hit(real_note)
					else:
						if pressed[real_note.note_data] and not note_data_possibles[real_note.note_data]:
							if just_pressed[real_note.note_data]:
								pop_up_score(real_note.strum_time, real_note)
								calculate_accuracy()
								
								real_note.being_pressed = true
								note_data_possibles[real_note.note_data] = true
								note_data_times[real_note.note_data] = real_note.strum_time
							
							#real_note.player_note_hit()
							if bf:
								bf.hold_timer = 0
								
			if not Options.get_data("ghost-tapping"):
				for i in len(just_pressed):
					if just_pressed[i] and not note_data_possibles[i] and not rythm_array[i]:
						note_miss(i)
							
	for note in notes.get_children():
		if note.sustain_length >= -50 and note.being_pressed and pressed[note.note_data]: 
			note.spr.visible = false
			note.sustain_length -= (delta * 1000) * GameplaySettings.song_multiplier
			
			if bf:
				bf.hold_timer = 0
				bf.play_anim(sing_anims[note.note_data], true)	
			
			var strum:Node2D = player_strums.get_child(note.note_data)			
			strum.play_anim("confirm")
			note.global_position.y = strum.global_position.y
			AudioHandler.voices.volume_db = 0
			
			if note.sustain_length <= -50:
				note.queue_free()
				
		# missing
		var sustainMissRange = 200
		
		var your = (note.must_press and note.sustain_length <= 0 and not botplay)
		var your2 = (note.must_press and note.sustain_length >= 0 and not pressed[note.note_data % GameplaySettings.key_count] and not botplay)
		
		if not pressed[note.note_data] and note.being_pressed and note.sustain_length <= sustainMissRange:
			note.sustain_length -= (delta * 1000) * GameplaySettings.song_multiplier
			note.global_position.y = player_strums.get_child(note.note_data % GameplaySettings.key_count).global_position.y
			
			AudioHandler.voices.volume_db = 0
			
			if note.sustain_length <= -50:
				note.queue_free()
		else:
			if your2 or (note.must_press and not note.being_pressed and pressed[note.note_data]):
				if Conductor.song_position > note.strum_time + Conductor.safe_zone_offset:
					if note.should_hit:
						note_miss(note.note_data)
						
						if note.sustain_length >= 150:
							health -= 0.2
						
					note.queue_free()
					
func good_note_hit(note):
	if not note.was_good_hit:
		pop_up_score(note.strum_time, note)
		
		#note.player_note_hit()
		
		if bf and bf.special_anim != true:
			bf.hold_timer = 0
			bf.play_anim(sing_anims[note.note_data], true)
		
		player_strums.get_child(note.note_data).play_anim("confirm")
		
		note.was_good_hit = true
		AudioHandler.voices.volume_db = 0
		
		calculate_accuracy()
		
		note.queue_free()
		
var cur_rating = "marvelous"
func pop_up_score(strum_time, note):
	health += 0.023 
	if health <= 0:
		health = 0
	if health > 2:
		health = 2
		
	var note_ms = (Conductor.song_position - strum_time) / GameplaySettings.song_multiplier
	
	var judgement_timings = [
		Options.get_data("sick-timing"),
		Options.get_data("good-timing"),
		Options.get_data("bad-timing"),
		Options.get_data("shit-timing")
	]
	
	var rating_scores = [350, 200, 100, 50]
	
	cur_rating = "marvelous"
	
	if abs(note_ms) >= judgement_timings[0]:
		cur_rating = "sick"
		
	if abs(note_ms) >= judgement_timings[1]:
		cur_rating = "good"
		
	if abs(note_ms) >= judgement_timings[2]:
		cur_rating = "bad"
		
	if abs(note_ms) >= judgement_timings[3]:
		cur_rating = "shit"
		
	var rating_tex = rating_textures[0]
	match cur_rating:
		"marvelous", "sick":
			if note_splashes:
				var splash = note_splash_template.duplicate()
				var strum = player_strums.get_child(note.note_data)
				splash.visible = true
				splash.global_position = strum.global_position
				splash.direction = strum.direction		
				splash.scale = player_strums.scale + Vector2(0.3, 0.3)
				hud.add_child(splash)
				splash.splash()
			
			song_score += rating_scores[0]
			
			if cur_rating == "sick":
				rating_tex = rating_textures[1]
				sicks += 1
			else:
				marvelous += 1
				
			total_hit += 1
		"good":
			goods += 1
			
			song_score += rating_scores[1]	
			rating_tex = rating_textures[2]
			
			total_hit += 0.7
		"bad":
			bads += 1
			
			song_score += rating_scores[2]	
			rating_tex = rating_textures[3]
			
			total_hit += 0.3
		"shit":
			shits += 1
			
			song_score += rating_scores[3]	
			rating_tex = rating_textures[4]
	
	combo += 1
	total_notes += 1
	
	var new_rating = rating_template.duplicate()
	
	var a = Options.get_data("rating-offset")
	
	new_rating.global_position = Vector2(654, 237) + Vector2(a[0], a[1])
	ratings.add_child(new_rating)
	
	new_rating.spr.texture = rating_tex
	
var rating_stuff:Array = [
		['bruj', 0.1], #your accuracy is actual garbage if you get to this point
		['F', 0.2], #From 0% to 19%
		['E', 0.4], #From 20% to 39%
		['D', 0.5], #From 40% to 49%
		['C', 0.6], #From 50% to 59%
		['B', 0.69], #From 60% to 68%
		['funni', 0.7], #69%
		['A', 0.8], #From 70% to 79%
		['S', 0.9], #From 80% to 89%
		['S+', 1], #From 90% to 99%
		['S++', 1] #100%
]
		
func calculate_accuracy():
	if total_hit != 0 and total_notes != 0:
		song_accuracy = (total_hit / total_notes)
	else:
		song_accuracy = 0
		
	if !is_nan(song_accuracy) and song_accuracy < 0:
		song_accuracy = 0
	
	if is_nan(song_accuracy):
		rating2 = "?"
	elif song_accuracy >= 1:
		song_accuracy = 1
		rating2 = rating_stuff[rating_stuff.size()-1][0] #Uses last string
	else:
		for i in rating_stuff.size()-1:
			if song_accuracy < rating_stuff[i][1]:
				rating2 = rating_stuff[i][0]
				break
		
	ratingtext.text = "Marvelous: " + str(marvelous)
	ratingtext.text += "\nSicks: " + str(sicks)
	ratingtext.text += "\nGoods: " + str(goods)
	ratingtext.text += "\nBads: " + str(bads)
	ratingtext.text += "\nShits: " + str(shits)
	ratingtext.text += "\nMisses: " + str(song_misses)
	
	rating1 = "Clear"
	
	if marvelous > 0 and sicks == 0 and goods == 0 and bads == 0 and shits == 0 and song_misses == 0:
		rating1 = "MFC"
		
	elif sicks > 0 and goods == 0 and bads == 0 and shits == 0 and song_misses == 0:
		rating1 = "SFC"
		
	elif goods > 0 and bads == 0 and shits == 0 and song_misses == 0:
		rating1 = "GFC"
		
	elif song_misses == 0:
		rating1 = "FC"
		
	elif song_misses < 10:
		rating1 = "SDCB"
	
	health_bar.scoretext.text = "Score: " + str(song_score) + " // Misses: " + str(song_misses) + " // Accuracy: " + str(CoolUtil.round_decimal(song_accuracy * 100, 2)) + "% [" + rating1 + " - " + rating2 + "]"
			
func note_miss(direction = 0):
	health -= 0.0475
	
	if health <= 0:
		health = 0
	
	song_misses += 1
	AudioHandler.voices.volume_db = -999
	
	if gf and combo > 5:
		gf.play_anim("sad")
		
	combo = 0
	song_score -= 10
	
	total_notes += 1
	calculate_accuracy()
	
	var miss_audio = "missnote" + str(randi()%3 + 1)
	AudioHandler.play_audio(miss_audio)
	
	if bf:
		bf.hold_timer = 0
		bf.play_anim(sing_anims[direction] + "miss", true)				
	
var old_keycount:int = -1
func refresh_input_bullshit():
	if old_keycount != GameplaySettings.key_count:
		old_keycount = GameplaySettings.key_count
		
		just_pressed = []
		pressed = []
		just_released = []
		released = []
		dont_hit = []
		
		for i in GameplaySettings.key_count:
			just_pressed.append(false)
			pressed.append(false)
			just_released.append(false)
			released.append(false)
			dont_hit.append(false)
			
var last_beat = 0
var last_step = 0
		
func beat_hit():
	if last_beat != Conductor.cur_beat:
		last_beat = Conductor.cur_beat
	else:
		return
	
	if bf != null:
		if bf.is_dancing() or bf.last_anim.ends_with("miss") or bf.last_anim == "hey" or bf.last_anim == "scared":
			bf.dance()
			
	if dad != null:
		if dad.is_dancing() or (SONG.player2 == gf_version and dad.last_anim == "cheer" or dad.last_anim == "scared"):
			dad.dance()
			
	if gf != null:
		if (gf.is_dancing() or gf.last_anim == "cheer" or gf.last_anim == "scared" or (gf.last_anim == "hairFall" and gf.anim_player.current_animation == "")) and dad != gf:
			gf.dance()
			
	if not countdown_active:
		iconP2.scale = Vector2(1.2, 1.2)
		iconP1.scale = Vector2(1.2, 1.2)
		
		if cam_zooming and Conductor.cur_beat % 4 == 0:
			camera.zoom -= Vector2(0.015, 0.015)
			
			hud.scale += Vector2(0.03, 0.03)
			hud.position.x = (hud.scale.x - 1) * -640
			hud.position.y = (hud.scale.y - 1) * -360
	
func step_hit():
	if last_step != Conductor.cur_step:
		last_step = Conductor.cur_step
	else:
		return
		
	if not countdown_active:
		var gaming = 30
		
		if GameplaySettings.song_multiplier >= 1:
			gaming *= GameplaySettings.song_multiplier
		
		if not ending_song and abs(AudioHandler.inst.get_playback_position() + (AudioServer.get_time_since_last_mix() * 1000) - (Conductor.song_position)) > gaming || (GameplaySettings.SONG.song.needsVoices && abs(AudioHandler.voices.get_playback_position() + (AudioServer.get_time_since_last_mix() * 1000) - (Conductor.song_position)) > gaming):
			resync_vocals()
			
		focus_camera()
			
func focus_on(character):
	match character:
		"gf", "girlfriend":
			if gf:
				var gorl = gf.global_position + gf.camera_pos
				camera.position = Vector2(gorl.x, gorl.y)
		"bf", "boyfriend":
			if bf:
				var boy = bf.global_position + bf.camera_pos
				camera.position = Vector2(boy.x, boy.y)
		_:
			if dad:
				var father = dad.global_position + dad.camera_pos
				
				if dad.is_player:
					father.x = dad.global_position.x + (dad.camera_pos.x + 250)
					
				camera.position = Vector2(father.x, father.y)
		
var cur_section:int = 0
		
func focus_camera():
	var prevSection = cur_section
	
	cur_section = floor(Conductor.cur_step / 16)
	
	if cur_section < 0:
		cur_section = 0
		
	if cur_section > len(SONG["notes"]) - 1:
		cur_section = len(SONG["notes"]) - 1
		
	if SONG["notes"][cur_section]["mustHitSection"]:
		focus_on("bf")
		if bf:
			timebar_progress.color = bf.health_color
		else:
			timebar_progress.color = Color("FFFFFF")
	else:
		focus_on("dad")
		if dad:
			timebar_progress.color = dad.health_color
		else:
			timebar_progress.color = Color("FFFFFF")
			
func reload_healthbar():
	if dad:
		iconP2.texture = dad.health_icon
		health_bar.color1.color = dad.health_color
		
	if bf:
		iconP1.texture = bf.health_icon
		health_bar.color2.color = bf.health_color
			
func resync_vocals():
	if not countdown_active:
		Conductor.song_position = (AudioHandler.inst.get_playback_position() * 1000)
		AudioHandler.voices.seek(Conductor.song_position / 1000)
