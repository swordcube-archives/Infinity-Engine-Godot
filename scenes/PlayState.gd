extends Node2D

var countdownActive:bool = true
var endingSong:bool = false

var stage:Node2D
var dad:Node2D
var gf:Node2D
var bf:Node2D

onready var camera = $Camera2D

onready var HUD = $HUD
onready var OTHER = $Other
onready var UI = $HUD/UI

var rawSONG = PlayStateSettings.SONG.song
var SONG:Song = Song.new()

var health:float = 1.0

var songScore:int = 0
var songMisses:int = 0

var marv:int = 0
var sicks:int = 0
var goods:int = 0
var bads:int = 0
var shits:int = 0
var misses:int = 0

var songAccuracy:float = 0.0

var totalNotes:int = 0
var totalHit:float = 0.0

var combo:int = 0

var defaultCamZoom:float = 1.0

var pressed:Array = [false]

var noteDataArray:Array = []
var loadedModcharts:Array = []

func sortAscending(a, b):
	if a[0] < b[0]:
		return true
	return false

func _init():
	PlayStateSettings.getSkin()
	PlayStateSettings.downScroll = Preferences.getOption("downscroll")
	PlayStateSettings.botPlay = Preferences.getOption("botplay")

onready var hitsound = $Hitsound

func _ready():
	if Preferences.getOption("hitsound") != "None":
		hitsound.stream = load(Paths.sound("hitsounds/" + Preferences.getOption("hitsound")))
		hitsound.volume_db = -5
		
	var dumbFuck:float = 1.0-float(Preferences.getOption("stage-opacity"))
	var real:float = dumbFuck
	$HUD/StageCoverup/bg.modulate.a = real
		
	$HUD/Version.text += " (" + CoolUtil.getTXT(Paths.txt("data/gameVersionDate"))[0] + ")"
	get_tree().paused = false
	
	for property in PlayStateSettings.SONG.song:
		if property in SONG:
			SONG.set(property, PlayStateSettings.SONG.song.get(property))
	
	Conductor.changeBPM(SONG.bpm, Conductor.mapBPMChanges(SONG))
	Conductor.songPosition = Conductor.timeBetweenBeats * -5
	Conductor.connect("beatHit", self, "beatHit")
	Conductor.connect("stepHit", self, "stepHit")
		
	var stageToLoad = SONG.stage
		
	if not Preferences.getOption("ultra-performance"):
		stage = Paths.getStageScene(stageToLoad)
		add_child(stage)
		
		var zoomThing = 1
		if stage:
			zoomThing = 1 - stage.defaultCamZoom
			
		var goodZoom = 1 + zoomThing
		
		camera.zoom = Vector2(goodZoom, goodZoom)
		defaultCamZoom = goodZoom
		
		var gfVersion = "gf"
		
		if "player3" in rawSONG:
			gfVersion = SONG.player3
			
		if "gfVersion" in rawSONG:
			gfVersion = SONG.gfVersion
			
		if "gf" in rawSONG:
			gfVersion = SONG.gf
		
		gf = Paths.getCharScene(gfVersion)
		add_child(gf)
		
		dad = Paths.getCharScene(SONG.player2)			
		if dad.isPlayer:
			dad.scale.x *= -1
		add_child(dad)
		
		if Preferences.getOption("play-as-opponent"):
			dad.isPlayer = not dad.isPlayer
		
		bf = Paths.getCharScene(SONG.player1)
		add_child(bf)
		
		if Preferences.getOption("play-as-opponent"):
			bf.isPlayer = not bf.isPlayer
		
		stage.createPost()
		
		dad.global_position += stage.get_node("dadPos").position + Vector2(300, 0)
		gf.global_position += stage.get_node("gfPos").position + Vector2(300, 0)
		bf.global_position += stage.get_node("bfPos").position + Vector2(300, 0)
	
	camera.smoothing_enabled = false
	moveCameraSection(!SONG.notes[0].mustHitSection)
	
	for balls_section in SONG.notes:
		var section:Section = Section.new()
		
		for property in balls_section:
			if property in section:
				section.set(property, balls_section.get(property))
				
		for note in section.sectionNotes:
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
					section.altAnim = false
					
				var offset:float = Preferences.getOption("note-offset") + (AudioServer.get_output_latency() * 1000)
				var strumTime:float = float(note[0]) + (offset * PlayStateSettings.songMultiplier)
				
				noteDataArray.push_back([
					strumTime, # strum time
					note[1], # note data
					note[2], # sussy length
					bool(section["mustHitSection"]), # must hit
					int(note[3]), # i forg
					type, # note type
					bool(section.altAnim) # alt note
				])
				
	noteDataArray.sort_custom(self, "sortAscending")
	
	PlayStateSettings.scrollSpeed = float(SONG.speed)
	match Preferences.getOption("scroll-speed-type"):
		"Multiplicative":
			PlayStateSettings.scrollSpeed *= float(Preferences.getOption("scroll-speed"))
		"Constant":
			PlayStateSettings.scrollSpeed = float(Preferences.getOption("scroll-speed"))
	
	PlayStateSettings.scrollSpeed *= 1.5
	PlayStateSettings.scrollSpeed /= PlayStateSettings.songMultiplier
	
	UI.healthBar._process(0)
	UI.healthBar.updateText()
	
	# loading modcharts!
	var songFolder:Array = CoolUtil.listFilesInDirectory(Paths.song(SONG.song))
	#print("SHIT IN SONG FOLDER: " + str(songFolder))
	for file in songFolder:
		if not file.begins_with(".") and file.ends_with(".tscn"):
			var modchartFile = load(Paths.song(SONG.song) + "/" + file).instance()
			modchartFile.PlayState = self
			loadedModcharts.append(modchartFile)
			add_child(modchartFile)
				
	var countdownTween:Tween = Tween.new()
	countdownTween.pause_mode = Node.PAUSE_MODE_PROCESS
	HUD.add_child(countdownTween)
	
	var countdownGraphic:Sprite = $HUD/CountdownGraphic
	var cs = PlayStateSettings.currentUiSkin.countdown_scale
	countdownGraphic.scale = Vector2(cs, cs)
	
	var countdownTime = (Conductor.timeBetweenBeats / 1000.0) / PlayStateSettings.songMultiplier
	callOnModcharts("onStartCountdown")
	for i in 5:
		yield(get_tree().create_timer(countdownTime, false), "timeout")
		match countdownTick:
			4:
				if dad and dad.isDancing():
					dad.dance()
				if gf and gf.isDancing():
					gf.dance()
				if bf and bf.isDancing():
					bf.dance()
				Conductor.songPosition = Conductor.timeBetweenBeats * -4
				countdownAudios["3"].stream = PlayStateSettings.currentUiSkin.countdown_3
				countdownAudios["3"].play()
				
				callOnModcharts("onCountdownTick", [countdownTick])
			3:
				if dad and dad.isDancing():
					dad.dance()
				if gf and gf.isDancing():
					gf.dance()
				if bf and bf.isDancing():
					bf.dance()
				Conductor.songPosition = Conductor.timeBetweenBeats * -3
				countdownAudios["2"].stream = PlayStateSettings.currentUiSkin.countdown_2
				countdownAudios["2"].play()
				
				countdownGraphic.texture = PlayStateSettings.currentUiSkin.ready_tex
				
				countdownTween.stop_all()
				countdownTween.interpolate_property(countdownGraphic, "modulate:a", 1, 0, countdownTime, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
				countdownTween.start()
				
				callOnModcharts("onCountdownTick", [countdownTick])
			2:
				if dad and dad.isDancing():
					dad.dance()
				if gf and gf.isDancing():
					gf.dance()
				if bf and bf.isDancing():
					bf.dance()
				Conductor.songPosition = Conductor.timeBetweenBeats * -2
				countdownAudios["1"].stream = PlayStateSettings.currentUiSkin.countdown_1
				countdownAudios["1"].play()
				
				countdownGraphic.texture = PlayStateSettings.currentUiSkin.set_tex
				
				countdownTween.stop_all()
				countdownTween.interpolate_property(countdownGraphic, "modulate:a", 1, 0, countdownTime, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
				countdownTween.start()
				
				callOnModcharts("onCountdownTick", [countdownTick])
			1:
				if dad and dad.isDancing():
					dad.dance()
				if gf and gf.isDancing():
					gf.dance()
				if bf and bf.isDancing():
					bf.dance()
				Conductor.songPosition = Conductor.timeBetweenBeats * -1
				
				countdownGraphic.texture = PlayStateSettings.currentUiSkin.go_tex
				
				countdownAudios["go"].stream = PlayStateSettings.currentUiSkin.countdown_go
				countdownAudios["go"].play()
				
				countdownTween.stop_all()
				countdownTween.interpolate_property(countdownGraphic, "modulate:a", 1, 0, countdownTime, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
				countdownTween.start()
				
				callOnModcharts("onCountdownTick", [countdownTick])
			0:
				if dad and dad.isDancing():
					dad.dance()
				if gf and gf.isDancing():
					gf.dance()
				if bf and bf.isDancing():
					bf.dance()
				AudioHandler.playInst(SONG.song)
				AudioHandler.playVoices(SONG.song)
				
				AudioHandler.inst.seek(0)
				AudioHandler.voices.seek(0)
				
				AudioHandler.inst.pitch_scale = PlayStateSettings.songMultiplier
				AudioHandler.voices.pitch_scale = PlayStateSettings.songMultiplier
				
				Conductor.songPosition = 0
				
				UI.timeBar = load(PlayStateSettings.currentUiSkin.time_bar_path).instance()
				var timeBarY:float = 20
				if PlayStateSettings.downScroll:
					timeBarY = CoolUtil.screenHeight - 20
				UI.timeBar.position = Vector2(640, timeBarY)
				UI.timeBar.modulate.a = 0
				UI.add_child(UI.timeBar)
				
				countdownTween.stop_all()
				countdownTween.interpolate_property(UI.timeBar, "modulate:a", 0, 1, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
				countdownTween.start()
				
				countdownActive = false
				
				camera.smoothing_enabled = true
				
				callOnModcharts("onCountdownTick", [countdownTick])
				callOnModcharts("onSongStart")
				
		countdownTick -= 1
		
	updatePresence()
	var timer = Timer.new()
	timer.one_shot = false
	add_child(timer)
	
	timer.start(1)
	timer.connect("timeout", self, "updatePresence")
				
var countdownTick:int = 4

onready var countdownAudios:Dictionary = {
	"3": $"HUD/3",
	"2": $"HUD/2",
	"1": $"HUD/1",
	"go": $HUD/Go
}

func updateHealth():
	if health < UI.healthBar.minHealth and not PlayStateSettings.practiceMode:
		health = UI.healthBar.minHealth
		endingSong = true
		Scenes.switchScene("GameOver", false)
		
		if bf:
			PlayStateSettings.deathCharacter = bf.deathCharacter
			PlayStateSettings.deathPosition = bf.global_position
			PlayStateSettings.deathCamPosition = camera.position
			PlayStateSettings.deathCamZoom = camera.zoom
		else:
			PlayStateSettings.deathCharacter = "bf-dead"
			PlayStateSettings.deathPosition = Vector2(1000, 500)
			PlayStateSettings.deathCamPosition = camera.position
			PlayStateSettings.deathCamZoom = camera.zoom
		
	if health > UI.healthBar.maxHealth:
		health = UI.healthBar.maxHealth
	
func _process(delta):		
	if Input.is_action_just_pressed("ui_back"):
		if UI.timeBar:
			UI.remove_child(UI.timeBar)
			UI.timeBar.queue_free()
		Scenes.switchScene("FreeplayMenu")
		AudioHandler.playMusic("freakyMenu")
		
	if not Scenes.transitioning and Input.is_action_just_pressed("ui_accept"):
		get_tree().paused = true
		var pauseMenu = load("res://scenes/ui/playState/PauseMenu.tscn").instance()
		OTHER.add_child(pauseMenu)
	
	Conductor.songPosition += (delta * 1000) * PlayStateSettings.songMultiplier

	updateHealth()
	
	camera.zoom = lerp(camera.zoom, Vector2(defaultCamZoom, defaultCamZoom), MathUtil.getLerpValue(0.05, delta))
	HUD.scale = lerp(HUD.scale, Vector2.ONE, MathUtil.getLerpValue(0.05, delta))
	HUD.offset.x = (HUD.scale.x - 1) * -CoolUtil.screenWidth/2
	HUD.offset.y = (HUD.scale.y - 1) * -CoolUtil.screenHeight/2
	
	for note in noteDataArray:
		var coc:float = PlayStateSettings.songMultiplier
		if coc < 1:
			coc = 1
			
		if float(note[0]) < Conductor.songPosition + ((2500 / PlayStateSettings.scrollSpeed) * coc):
			var mustPress = true
			
			if note[3] and int(note[1]) % (SONG.keyCount * 2) >= SONG.keyCount:
				mustPress = false
			elif !note[3] and int(note[1]) % (SONG.keyCount * 2) <= SONG.keyCount - 1:
				mustPress = false
				
			var strum:Node2D = UI.opponentStrums.get_child(int(note[1]) % SONG.keyCount)
			if mustPress:
				strum = UI.playerStrums.get_child(int(note[1]) % SONG.keyCount)
				
			if Preferences.getOption("play-as-opponent"):
				mustPress = not mustPress
				
			var newNote:Node2D = load("res://scenes/ui/notes/Default.tscn").instance()
			newNote.noteData = int(note[1]) % SONG.keyCount
			newNote.strumTime = float(note[0])
			newNote.direction = strum.direction
			newNote.sustainLength = float(note[2])/1.5
			newNote.ogSustainLength = newNote.sustainLength
			newNote.downScroll = PlayStateSettings.downScroll
			newNote.altNote = note[6]
			newNote.get_node("Line2D").position.y = -5000
			newNote.position.y = -5000
			strum.notes.add_child(newNote)
		
			newNote.mustPress = mustPress
			
			noteDataArray.erase(note)
		else:
			break
			
	if not countdownActive:
		if Conductor.songPosition / 1000.0 >= AudioHandler.inst.stream.get_length() - 0.25:
			endSong()
			
func endSong():
	endingSong = true
	
	if UI.timeBar:
		UI.remove_child(UI.timeBar)
		UI.timeBar.queue_free()
	
	get_tree().paused = true
	
	var resultsScreen = load("res://scenes/ui/playState/ResultsScreen.tscn").instance()
	resultsScreen.score = songScore
	resultsScreen.accuracy = MathUtil.roundDecimal(songAccuracy * 100, 2)
	resultsScreen.marv = marv
	resultsScreen.sicks = sicks
	resultsScreen.goods = goods
	resultsScreen.bads = bads
	resultsScreen.shits = shits
	resultsScreen.misses = songMisses
	OTHER.add_child(resultsScreen)
	
	AudioHandler.inst.stop()
	AudioHandler.voices.stop()
	
func actuallyEndSong():
	var piss:String = ""
	if Preferences.getOption("play-as-opponent"):
		piss = "-opponent-play"
		
	if PlayStateSettings.songMultiplier >= 1:
		if songScore > Highscore.getScore(SONG.song + piss, PlayStateSettings.difficulty):
			Highscore.setScore(SONG.song + piss, PlayStateSettings.difficulty, songScore)
		
	if PlayStateSettings.storyMode:
		Scenes.switchScene("StoryMenu")
	else:
		Scenes.switchScene("FreeplayMenu")
		
	AudioHandler.playMusic("freakyMenu")
			
func beatHit():
	if bf:
		if bf.isDancing():# or bf.lastAnim.ends_with("miss") or bf.lastAnim == "hey" or bf.lastAnim == "scared":
			bf.dance()
			
	if dad:
		if dad.isDancing():# or (dad.name == gf.name and dad.lastAnim == "cheer" or dad.lastAnim == "scared"):
			dad.dance()
			
	if gf:
		if gf.isDancing():#(gf.isDancing() or gf.lastAnim == "sad" or gf.lastAnim == "cheer" or gf.lastAnim == "scared" or (gf.lastAnim == "hairFall" and gf.animPlayer.get_current_animation_position() >= 0.26)) and dad != gf:
			gf.dance()
			
	if Conductor.curBeat % 4 == 0:
		camera.zoom -= Vector2(0.015, 0.015)
		HUD.scale += Vector2(0.05, 0.05)
		HUD.offset.x = (HUD.scale.x - 1) * -CoolUtil.screenWidth/2
		HUD.offset.y = (HUD.scale.y - 1) * -CoolUtil.screenHeight/2
			
func stepHit():
	var curSection:int = int(Conductor.curStep / 16)
	if curSection < 0:
		curSection = 0
	if curSection > SONG.notes.size() - 1:
		curSection = SONG.notes.size() - 1
		
	moveCameraSection(!SONG.notes[curSection].mustHitSection)
		
	if not countdownActive:
		var gaming = 30
		
		if PlayStateSettings.songMultiplier > 1:
			gaming *= PlayStateSettings.songMultiplier
			
		var inst_pos = (AudioHandler.inst.get_playback_position() * 1000) + (AudioServer.get_time_since_last_mix() * 1000)
		inst_pos -= AudioServer.get_output_latency() * 1000
		
		if not Conductor.songPosition / 1000.0 >= AudioHandler.inst.stream.get_length():
			if not endingSong and inst_pos > Conductor.songPosition - (AudioServer.get_output_latency() * 1000) + gaming or inst_pos < Conductor.songPosition - (AudioServer.get_output_latency() * 1000) - gaming:
				resyncVocals()
			
func moveCameraSection(isDad:bool = false):
	if isDad:
		if dad:
			camera.position.x = (dad.getMidpoint().x + 0) + dad.camera_pos.x
			camera.position.y = (dad.getMidpoint().y - 100) + dad.camera_pos.y
	else:
		if bf:
			camera.position.x = (bf.getMidpoint().x - 430) - bf.camera_pos.x
			camera.position.y = (bf.getMidpoint().y - 100) + bf.camera_pos.y
		
func callOnModcharts(funct:String, args:Array = []):
	if loadedModcharts.size() > 0:
		for m in loadedModcharts:
			var modchart:Modchart = m
			modchart.callv(funct, args)
			
func resyncVocals():
	if not countdownActive:
		Conductor.songPosition = (AudioHandler.inst.get_playback_position() * 1000)
		AudioHandler.voices.seek(Conductor.songPosition / 1000)
		
func updatePresence():
	if AudioHandler.inst.stream:
		Discord.update_presence("Playing "+SONG.song+" ("+PlayStateSettings.difficulty+")", "Time Left: "+CoolUtil.formatTime((AudioHandler.inst.stream.get_length()/PlayStateSettings.songMultiplier) - (Conductor.songPosition / 1000.0)/PlayStateSettings.songMultiplier))
	else:
		Discord.update_presence("Starting "+SONG.song+" ("+PlayStateSettings.difficulty+")")
