extends Node2D

var health:float = 1.0

var countdown_tween:Tween = Tween.new()
var timebar_tween:Tween = Tween.new()

var SONG

var gf_version:String = "gf"
var curStage:String = "stage"

var stage:Node2D

var dad:Node2D
var gf:Node2D
var boyfriend:Node2D

var song_score:int = 0
var song_misses:int = 0

var total_notes_hit = 0

var song_accuracy:float = 0.0

var default_cam_zoom:float = 1.1

var countdown_counter:int = -1

var unspawnNotes:Array = []

var speed:float = 1.0

var in_cutscene:bool = false
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

func _ready():
	if(Gameplay.SONG == null): # load tutorial if the song can't be found
		var song = "res://Assets/Songs/Tutorial/hard"
		print("SONG TO LOAD: " + song)
		Gameplay.SONG = JsonUtil.get_json(song)
		
	SONG = Gameplay.SONG.song
	
	speed = SONG.speed
			
	Conductor.songPosition = 0
	Conductor.curBeat = 0
	Conductor.curStep = 0
	Conductor.change_bpm(SONG.bpm)
	Conductor.recalculate_values()
	
	Conductor.connect("beat_hit", self, "beat_hit")
	Conductor.connect("step_hit", self, "step_hit")
	
	$Misc/Transition._fade_out()
	
	# add the stage
	match(SONG.song.to_lower()):
		"tutorial", "bopeebo", "fresh", "dad battle":
			gf_version = "gf"
			curStage = "stage"
		"spookeez", "south", "monster":
			gf_version = "gf"
			curStage = "spooky"
		"pico", "philly nice", "blammed":
			gf_version = "gf"
			curStage = "philly"
		"satin panties", "high", "m.i.l.f":
			gf_version = "gf"
			curStage = "limo"
		"cocoa", "eggnog", "winter horrorland":
			gf_version = "gf-christmas"
			curStage = "mall"
		"winter horrorland":
			curStage = "mallEvil"
		"senpai", "roses", "thorns":
			gf_version = "gf-pixel"
			curStage = "school"
		"roses":
			curStage = "schoolAngry"
		"thorns":
			curStage = "schoolEvil"
		_:
			gf_version = SONG.gfVersion
			curStage = "stage"
			
	var stageLoaded = load("res://Stages/" + curStage + "/stage.tscn")
	
	if stageLoaded == null:
		stageLoaded = load("res://Stages/stage/stage.tscn")
	
	stage = stageLoaded.instance()
	add_child(stage)
	
	# add dad
	var dadLoaded = load("res://Characters/" + SONG.player2.to_lower() + "/char.tscn")
	
	if dadLoaded == null:
		dadLoaded = load("res://Characters/dad/char.tscn")
	
	dad = dadLoaded.instance()
	dad.global_position = stage.get_node("dad_pos").position
	add_child(dad)
	
	# add gf		
	var gfLoaded = load("res://Characters/" + gf_version.to_lower() + "/char.tscn")
	
	if gfLoaded == null:
		gfLoaded = load("res://Characters/gf/char.tscn")
	
	gf = gfLoaded.instance()
	gf.global_position = stage.get_node("gf_pos").position
	add_child(gf)
	
	if dadLoaded == gfLoaded:
		dad.global_position = stage.get_node("gf_pos").position
		gf.visible = false
	
	# add boyfriend
	var bfLoaded = load("res://Characters/" + SONG.player1.to_lower() + "/char.tscn")
	
	if bfLoaded == null:
		bfLoaded = load("res://Characters/bf/char.tscn")
	
	boyfriend = bfLoaded.instance()
	boyfriend.global_position = stage.get_node("bf_pos").position
	add_child(boyfriend)
	
	$camHUD/TimeBar/FGColor.color = dad.health_color
	$camGame.position = dad.global_position + dad.get_node("camera_pos").position	
	
	change_dad_icon(dad.health_icon)
	change_bf_icon(boyfriend.health_icon)
	
	change_dad_health_color(dad.health_color)
	change_bf_health_color(boyfriend.health_color)
	
	$camGame.zoom = Vector2(default_cam_zoom, default_cam_zoom)
	
	generate_notes()
	
	Conductor.songPosition = Conductor.timeBetweenBeats * -4.5
	
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
	Conductor.songPosition += (delta * 1000)
	
	$camHUD/BotplayText.visible = Options.get_data("botplay")
	
	botplay_text_sine += 180 * delta;
	$camHUD/BotplayText.modulate.a = 1 - sin((PI * botplay_text_sine) / 180);
	
	if $camHUD/BotplayText.modulate.a > 1:
		$camHUD/BotplayText.modulate.a = 1
	
	if not countdown_active:
		inst_time = AudioHandler.get_node("Inst").get_playback_position() * 1000
		voices_time = AudioHandler.get_node("Voices").get_playback_position() * 1000
		
		var length = AudioHandler.get_node("Inst").stream.get_length() * 1000
		
		#print(format_time(time / 1000, false))
		$camHUD/TimeBar/TimeText.text = Util.format_time(inst_time / 1000, false) + " / " + Util.format_time(length / 1000, false)
		
		$camHUD/TimeBar/FGColor.rect_scale.x = (inst_time / length)

		if inst_time >= length:
			AudioHandler.play_audio("freakyMenu")
			$Misc/Transition.transition_to_scene("FreeplayMenu")

	$camHUD/ScoreText.bbcode_text = "[center]Score: " + str(song_score) + " // Misses: " + str(song_misses) + " // Accuracy: " + str(Util.round_decimal(song_accuracy * 100, 2)) + "%"
	
	if Options.get_data("botplay"):
		$camHUD/ScoreText.bbcode_text += " // BOTPLAY"
		$camHUD/TimeBar/TimeText.text += " [BOT]"
	
	$camHUD/HealthBar/BFColor.rect_scale.x = health / 2
	
	if len(unspawnNotes) > 0:
		if (len(unspawnNotes) > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < 3500):
			var dunceNote:Node2D = unspawnNotes[0];
			$camHUD/Notes.add_child(dunceNote);

			unspawnNotes.remove(0) # wouldn't this work too? lmao??
			
	for note in $camHUD/Notes.get_children():
		var strum
		if note.mustPress:
			strum = $camHUD/PlayerStrums.get_children()[note.noteData % 4]
		else:
			strum = $camHUD/OpponentStrums.get_children()[note.noteData % 4]
			
		if note.mustPress:
			note.global_position.y = strum.global_position.y + (0.45 * (Conductor.songPosition - note.strumTime) * Util.round_decimal(speed, 2))
		else:
			note.global_position.y = strum.global_position.y + (0.45 * (Conductor.songPosition - note.strumTime) * Util.round_decimal(speed, 2))
			
			# opponent notes
			if not countdown_active:
				if Conductor.songPosition >= note.strumTime:
					#AudioHandler.get_node("Voices").play()
					#AudioHandler.get_node("Voices").seek(AudioHandler.get_node("Inst").get_playback_position())
					
					if not dad.special_anim:
						dad.play_anim(sing_anims[note.noteData % 4], true)
					
					AudioHandler.get_node("Voices").volume_db = 0
					
					strum.frame = 0
					strum.play(letter_directions[note.noteData % 4] + " confirm")
					note.get_node("Note").visible = false
					
					note.global_position.y = strum.global_position.y
					note.sustainLength -= (delta * (650 * speed))
					if note.sustainLength <= 0:
						$camHUD/Notes.remove_child(note)

			
		# missing
		if note.mustPress and not pressed[note.noteData % 4] and not Options.get_data("botplay"):
			if Conductor.songPosition > note.strumTime + Conductor.safeZoneOffset:
				song_score -= 10
				song_misses += 1
				#total_notes_hit += 1
				combo = 0
				health -= 0.0475
				
				calculate_accuracy()
				
				if not boyfriend.special_anim:
					boyfriend.play_anim(sing_anims[note.noteData % 4] + "miss", true)
				
				AudioHandler.get_node("Voices").volume_db = -999
				$camHUD/Notes.remove_child(note)
			
	var strum_confirm_i = 0
	for strum in $camHUD/OpponentStrums.get_children():
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
				1:
					AudioHandler.play_countdown(countdown_counter)
					
					var ready = load("res://Scenes/Gameplay/Ready.tscn").instance()
					ready.texture = load("res://Assets/Images/UI Skins/" + Gameplay.ui_Skin + "/ready.png")
					countdown_tween.interpolate_property(ready, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), Conductor.timeBetweenBeats / 1000, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
					add_child(countdown_tween)
					countdown_tween.start()
					$camHUD.add_child(ready)
				2:
					AudioHandler.play_countdown(countdown_counter)
					
					var set = load("res://Scenes/Gameplay/Set.tscn").instance()
					set.texture = load("res://Assets/Images/UI Skins/" + Gameplay.ui_Skin + "/set.png")
					countdown_tween.interpolate_property(set, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), Conductor.timeBetweenBeats / 1000, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
					countdown_tween.start()
					$camHUD.add_child(set)
				3:
					AudioHandler.play_countdown(countdown_counter)
					
					var go = load("res://Scenes/Gameplay/Go.tscn").instance()
					go.texture = load("res://Assets/Images/UI Skins/" + Gameplay.ui_Skin + "/go.png")
					countdown_tween.interpolate_property(go, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), Conductor.timeBetweenBeats / 1000, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
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
					
					Conductor.songPosition = 0.0
					countdown_active = false
		
					timebar_tween.interpolate_property($camHUD/TimeBar, "modulate", $camHUD/TimeBar.modulate, Color(1, 1, 1, 1), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
					add_child(timebar_tween)
					timebar_tween.start()
					
	key_shit(delta)
	
	if not pressed.has(true):
		if boyfriend.hold_timer > Conductor.timeBetweenSteps * 0.001 * boyfriend.sing_duration and boyfriend.get_node("frames").animation.begins_with("sing") and not boyfriend.get_node("frames").animation.ends_with("miss"):
			boyfriend.dance()
	else:
		boyfriend.hold_timer = 0
	
	for note in $camHUD/Notes.get_children():
		if note.mustPress and note.sustainLength > 0 and pressed[note.noteData % 4] and Conductor.songPosition >= note.strumTime or Options.get_data("botplay") and note.mustPress and note.sustainLength > 0 and Conductor.songPosition >= note.strumTime:
			var strum = $camHUD/PlayerStrums.get_children()[note.noteData % 4]
			
			strum.frame = 0
			strum.play(letter_directions[note.noteData % 4] + " confirm")
			
			if not boyfriend.special_anim:
				boyfriend.play_anim(sing_anims[note.noteData % 4], true)
			
			AudioHandler.get_node("Voices").volume_db = 0
			
			health += 0.023 / 5
			
			note.global_position.y = strum.global_position.y
			note.sustainLength -= (delta * (650 * speed))
			if note.sustainLength <= 0:
				$camHUD/Notes.remove_child(note)
				
	if health < 0:
		health = 0
	if health > 2:
		health = 2
	
	camera_zooms(delta)
	icon_zooms(delta)
	
func generate_notes():
	var noteData:Array
	
	noteData = SONG.notes
	
	for section in noteData:
		for songNotes in section.sectionNotes:
			var daStrumTime:float = songNotes[0] + Options.get_data("note-offset")
			var daNoteData:int = int(songNotes[1]) % 4
			
			var gottaHitNote:bool = section.mustHitSection
			
			if songNotes[1] > 3:
				gottaHitNote = !section.mustHitSection
			
			var oldNote:Node2D
			
			if len(unspawnNotes) > 0:
				oldNote = unspawnNotes[len(unspawnNotes) - 1]
			else:
				oldNote = null
				
			var swagNote = load("res://Scenes/Notes/Note.tscn").instance()
			if gottaHitNote:
				swagNote.global_position.x = $camHUD/PlayerStrums.get_children()[daNoteData].global_position.x
			else:
				swagNote.global_position.x = $camHUD/OpponentStrums.get_children()[daNoteData].global_position.x
			swagNote.noteData = daNoteData
			swagNote.strumTime = daStrumTime
			swagNote.mustPress = gottaHitNote
			swagNote.sustainLength = songNotes[2] - 240
			
			if swagNote.sustainLength < 0:
				swagNote.sustainLength = 0
			
			swagNote.set_direction()
			swagNote.get_node("Line2D").texture = load("res://Assets/Images/UI Skins/" + Gameplay.ui_Skin + "/Sustains/" + swagNote.dir_string + " hold0000.png")
			swagNote.get_node("End").play(swagNote.dir_string + " tail")
			
			unspawnNotes.append(swagNote)
			
	#print(unspawnNotes)
	
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
	just_pressed = [false, false, false, false]
	just_released = [false, false, false, false]
	pressed = [false, false, false, false]
	released = [false, false, false, false]
	
	if not Options.get_data("botplay"):
		for i in 4:
			just_pressed[i] = Input.is_action_just_pressed("gameplay_" + str(i))
			pressed[i] = Input.is_action_pressed("gameplay_" + str(i))
			released[i] = not Input.is_action_pressed("gameplay_" + str(i))
			
		for i in len(just_pressed):
			if just_pressed[i] == true:
				$camHUD/PlayerStrums.get_children()[i].play(letter_directions[i] + " press")
				
		for i in len(released):
			if released[i] == true:
				$camHUD/PlayerStrums.get_children()[i].play("arrow" + directions[i])
	else:
		for i in len(released):
			if $camHUD/PlayerStrums.get_children()[i].frame == 3:
				$camHUD/PlayerStrums.get_children()[i].play("arrow" + directions[i])
		
	var possibleNotes = []
	
	for note in $camHUD/Notes.get_children():
		note.calculate_can_be_hit()
		
		if not Options.get_data("botplay"):
			if note.canBeHit and note.mustPress and not note.tooLate and not note.isSustainNote:
				possibleNotes.append(note)
		else:
			if note.strumTime <= Conductor.songPosition and note.mustPress:
				possibleNotes.append(note)
				
	#possibleNotes.sort_custom(self, "sort_notes")
	
	var dont_hit = [false, false, false, false]
	var note_data_times = [-1, -1, -1, -1]
	
	if len(possibleNotes) > 0:
		for i in len(possibleNotes):
			var note = possibleNotes[i]
			
			if (just_pressed[note.noteData % 4] and not dont_hit[note.noteData % 4] and not Options.get_data("botplay")) or Options.get_data("botplay"):
				if not note.beingPressed:
					var rating_scores = [350, 200, 100, 50]
					
					var note_ms = Conductor.songPosition - note.strumTime
					
					if Options.get_data("botplay"):
						note_ms = 0
						
					note_ms = Util.round_decimal(note_ms, 3)
					
					var judgement_timings = [
						22.5, # sick
						45, # good
						85, # bad
						100 # shit
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
						
					match(cur_rating):
						"marvelous", "sick":
							total_notes_hit += 1
							
							if cur_rating == "marvelous":
								marvelous += 1
							else:
								sicks += 1
							
							var note_splash = preload("res://Scenes/Gameplay/NoteSplash.tscn").instance()
							note_splash.noteData = note.noteData % 4
							note_splash.global_position = $camHUD/PlayerStrums.get_children()[note.noteData % 4].global_position
							$camHUD.add_child(note_splash)
						"good":
							total_notes_hit += 0.75
							goods += 1
						"bad":
							total_notes_hit += 0.5
							bads += 1
						"shit":
							total_notes_hit += 0
							shits += 1
						
					var rating = preload("res://Scenes/Gameplay/Rating.tscn").instance()
					rating.name = "Rating" + str(hits)
					rating.get_node("Sprite").texture = load("res://Assets/Images/UI Skins/" + Gameplay.ui_Skin + "/" + cur_rating + ".png")
					rating.modulate.a = 1
					rating.visible = true
					rating.combo = combo
					hits += 1
					combo += 1
					$camHUD.add_child(rating)
					
					calculate_accuracy()
					
					health += 0.023
						
					dont_hit[note.noteData % 4] = true
					pressed[note.noteData % 4] = true
					
					if not boyfriend.special_anim:
						boyfriend.play_anim(sing_anims[note.noteData % 4], true)
					
					AudioHandler.get_node("Voices").volume_db = 0
					
					var strum = $camHUD/PlayerStrums.get_children()[note.noteData % 4]
					strum.play(letter_directions[note.noteData % 4] + " confirm")
					
					note.get_node("Note").visible = false
					
					if note.sustainLength <= 0:
						$camHUD/Notes.remove_child(note)
					
					if note.sustainLength > 0:
						note.beingPressed = true
					
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
	return int(a.strumTime - b.strumTime)
	
func beat_hit():
	if boyfriend != null:
		if not boyfriend.get_node("anim").current_animation.begins_with("sing"):
			boyfriend.dance()
			
	if dad != null:
		if dad.is_dancing():
			dad.dance()
			
	if gf != null:
		if gf.is_dancing() and dad != gf:
			gf.dance()
			
	if not countdown_active:
		$camHUD/HealthBar/IconP2.scale = Vector2(1.2, 1.2)
		$camHUD/HealthBar/IconP1.scale = Vector2(-1.2, 1.2)
		
		if Conductor.curBeat % 4 == 0:
			$camGame.zoom = Vector2(default_cam_zoom, default_cam_zoom) * 0.98
			$camHUD.scale = Vector2(1.03, 1.03)
			
	# HARDCODED EVENTS UNTIL I ADD UNHARDCODED ONES!!!
	if Conductor.curBeat % 8 == 7 && SONG.song.to_lower() == 'bopeebo':
		boyfriend.special_anim = true
		boyfriend.play_anim('hey', true)

	if Conductor.curBeat % 16 == 15 && SONG.song.to_lower() == 'tutorial' && Conductor.curBeat > 16 && Conductor.curBeat < 48:
		boyfriend.special_anim = true
		boyfriend.play_anim('hey', true)
		
		dad.special_anim = true
		dad.play_anim('cheer', true)
	
	elif Conductor.curBeat % 16 == 15 && SONG.song.to_lower() == 'tutorial' && Conductor.curBeat > 16 && Conductor.curBeat < 48:
		boyfriend.special_anim = true
		boyfriend.play_anim('hey', true)
		
		gf.special_anim = true
		gf.play_anim('cheer', true)

var curSection:int = 0

var mustHitSection = false

func resync_vocals():
	AudioHandler.get_node("Inst").seek(Conductor.songPosition / 1000)
	AudioHandler.get_node("Voices").seek(Conductor.songPosition / 1000)

func step_hit():
	if abs(inst_time - (Conductor.songPosition)) > 20 || (SONG.needsVoices && abs(voices_time - (Conductor.songPosition)) > 20):
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
