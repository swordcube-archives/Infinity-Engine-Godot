extends Node2D

onready var camera = $Camera2D
onready var hud = $CanvasLayer/HUD

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

var countdown_active:bool = true
var SONG:Dictionary = GameplaySettings.SONG.song

var cam_zooming:bool = false

var noteDataArray:Array = []

var just_pressed:Array = []
var pressed:Array = []
var just_released:Array = []
var released:Array = []

func _ready():	
	Keybinds.setup_Binds()	
	GameplaySettings.load_ui_skin()
	
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
	
func _physics_process(delta):
	iconP2.scale = lerp(iconP2.scale, Vector2.ONE, delta * 20)
	iconP1.scale = lerp(iconP1.scale, Vector2.ONE, delta * 20)
	
	if cam_zooming:
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
			
			print("STINKY:" + str(note[1]))
			new_note.note_data = int(note[1]) % GameplaySettings.key_count
			
			if "is_alt" in new_note:
				new_note.is_alt = note[6]
			
			if int(note[4]) != null:
				if "character" in new_note:
					new_note.character = note[4]
					
			if float(note[2]) >= Conductor.step_crochet:
				new_note.sustain_length = float(note[2])
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

func start_countdown():
	farded = true
	countdown_tick()
	for i in 4:
		yield(get_tree().create_timer(Conductor.crochet / 1000.0), "timeout")
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
	print("COUNTDOWN: " + str(countdown))
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
		
func _process(delta):
	if not Transition.transitioning:
		if countdown_active:
			Conductor.song_position += (delta * 1000)
		else:
			Conductor.song_position += (delta * 1000) * GameplaySettings.song_multiplier
			
	if Input.is_action_just_pressed("ui_back"):
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
			
		# FINISH INPUT SYSTEM TOMORROW!
	
var old_keycount:int = -1
func refresh_input_bullshit():
	if old_keycount != GameplaySettings.key_count:
		old_keycount = GameplaySettings.key_count
		
		just_pressed = []
		pressed = []
		just_released = []
		released = []
		
		for i in GameplaySettings.key_count:
			just_pressed.append(false)
			pressed.append(false)
			just_released.append(false)
			released.append(false)
		
func beat_hit():
	if not countdown_active:
		iconP2.scale = Vector2(1.2, 1.2)
		iconP1.scale = Vector2(1.2, 1.2)
		
		if cam_zooming and Conductor.cur_beat % 4 == 0:
			hud.scale += Vector2(0.03, 0.03)
			hud.position.x = (hud.scale.x - 1) * -640
			hud.position.y = (hud.scale.y - 1) * -360
	
func step_hit():
	pass
