extends Node2D

var songTemplate:FreeplaySong = load("res://scenes/ui/freeplay/SongTemplate.tscn").instance()

onready var bg = $BG
onready var songUtil = $SongUtil
onready var songs = $Songs

onready var scoreText = $ScoreText
onready var scoreBG = $ScoreBG
onready var diffText = $DiffText

onready var speedText = $SpeedText

var songMakerDifficultyList:Array = []

var songNames:Array = []
var songColors:Array = []
var songDifficulties:Array = []

var curSelected:int = 0
var curDifficulty:int = 0

var curSpeed:float = 1.0

func _ready():
	AudioHandler.playMusic("freakyMenu")
	
	if not OS.is_debug_build():
		$AddNewSong.visible = false
		
	songUtil.visible = false
	
	var i:int = 0
	
	var txt = CoolUtil.getTXT(Paths.txt("data/freeplaySongs"))
	for item in txt:
		var split = item.split(":")
		if len(item) > 0:
			if OS.is_debug_build() or not (range(split.size()).has(4) and split[4] == "DEBUG_ONLY"):
				songNames.append(split[0])
				songColors.append(split[2])
				songDifficulties.append(split[3].split(","))
				
				var newSong:FreeplaySong = songTemplate.duplicate()
				newSong.position.x = 30
				newSong.position.y = (70 * i) + 30
				songs.add_child(newSong)
				
				newSong.label.text = split[0]
				newSong.label.updateText()
				
				newSong.isMenuItem = true
				newSong.targetY = i
				
				newSong.icon.texture = load(Paths.healthIcon(split[1]))
				newSong.icon.position.x = newSong.label.label.rect_size.x + 70
				
				i += 1
			
	changeSelection()
	changeDifficulty()
	positionHighscore()
	
	AudioHandler.setMusicPitch(curSpeed)
	
	Discord.update_presence("In the Freeplay Menu")
	
var lerpScore:float = 0.0

var holdTimer:float = 0.0

func _process(delta):
	bg.modulate = lerp(bg.modulate, Color(songColors[curSelected]), MathUtil.getLerpValue(0.045, delta))
	
	var piss:String = ""
	if Preferences.getOption("play-as-opponent"):
		piss = "-opponent-play"
	
	lerpScore = lerp(lerpScore, Highscore.getScore(songNames[curSelected] + piss, songDifficulties[curSelected][curDifficulty]), MathUtil.getLerpValue(0.35, delta))
	scoreText.text = "PERSONAL BEST: " + str(round(abs(lerpScore)))
	speedText.text = "Speed: " + str(MathUtil.roundDecimal(curSpeed, 2))
	positionHighscore()
	
	if not songUtil.visible:
		if Input.is_action_just_pressed("ui_back"):
			Scenes.switchScene("MainMenu")
			AudioHandler.playSFX("cancelMenu")
			
		if Input.is_action_just_pressed("ui_up"):
			changeSelection(-1)
			
		if Input.is_action_just_pressed("ui_down"):
			changeSelection(1)
			
		if Input.is_action_just_pressed("ctrl"):
			get_tree().paused = true
			var gameplayModifiers = load("res://scenes/ui/freeplay/GameplayModifiers.tscn").instance()
			add_child(gameplayModifiers)
			
		if Input.is_action_pressed("ui_shift"):
			var vector = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
			if vector.x != 0:
				holdTimer += delta
				if (Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right")) or holdTimer > 0.5:
					curSpeed += vector.x * 0.05
					if curSpeed < 0.05:
						curSpeed = 0.05
					AudioHandler.setMusicPitch(MathUtil.roundDecimal(curSpeed, 2))
			else:
				holdTimer = 0.0
		else:
			holdTimer = 0.0
			if Input.is_action_just_pressed("ui_left"):
				changeDifficulty(-1)
				
			if Input.is_action_just_pressed("ui_right"):
				changeDifficulty(1)
			
		if curPlaying != songNames[curSelected] and Input.is_action_just_pressed("ui_space"):
			curPlaying = songNames[curSelected]
			AudioHandler.playInst(songNames[curSelected])
			AudioHandler.playVoices(songNames[curSelected])
			
			AudioHandler.inst.seek(0)
			AudioHandler.voices.seek(0)
		elif Input.is_action_just_pressed("ui_accept"):
			AudioHandler.stopMusic()
			PlayStateSettings.deaths = 0
			PlayStateSettings.practiceMode = false
			PlayStateSettings.usedPractice = false
			PlayStateSettings.availableDifficulties = songDifficulties[curSelected]
			PlayStateSettings.difficulty = songDifficulties[curSelected][curDifficulty]
			PlayStateSettings.SONG = CoolUtil.getJSON(Paths.songJSON(songNames[curSelected], PlayStateSettings.difficulty))
			PlayStateSettings.songMultiplier = MathUtil.roundDecimal(curSpeed, 2)
			Scenes.switchScene("PlayState")
			
var curPlaying:String = ""
		
func changeSelection(change:int = 0):
	curSelected += change
	if curSelected < 0:
		curSelected = songs.get_child_count() - 1
	if curSelected > songs.get_child_count() - 1:
		curSelected = 0
		
	for i in songs.get_child_count():
		songs.get_child(i).targetY = i - curSelected
		if curSelected == i:
			songs.get_child(i).modulate.a = 1
		else:
			songs.get_child(i).modulate.a = 0.6
			
	AudioHandler.playSFX("scrollMenu")
	changeDifficulty()
	
	Discord.update_presence("In the Freeplay Menu", "Selecting "+songNames[curSelected]+" ("+songDifficulties[curSelected][curDifficulty]+")")
			
func changeDifficulty(change:int = 0):
	curDifficulty += change
	if curDifficulty < 0:
		curDifficulty = songDifficulties[curSelected].size() - 1
	if curDifficulty > songDifficulties[curSelected].size() - 1:
		curDifficulty = 0
		
	diffText.text = "< "+songDifficulties[curSelected][curDifficulty].to_upper()+" >"	
	positionHighscore()
	
	Discord.update_presence("In the Freeplay Menu", "Selecting "+songNames[curSelected]+" ("+songDifficulties[curSelected][curDifficulty]+")")
	
func positionHighscore():
	scoreText.rect_size.x = 0
	diffText.rect_size.x = 0
	speedText.rect_size.x = 0
	
	scoreText.rect_position.x = CoolUtil.screenWidth - scoreText.rect_size.x - 6
	scoreBG.rect_scale.x = CoolUtil.screenWidth - scoreText.rect_position.x + 6
	scoreBG.rect_position.x = CoolUtil.screenWidth - scoreBG.rect_scale.x / 300
	diffText.rect_position.x = scoreBG.rect_position.x - (scoreBG.rect_scale.x / 2)
	diffText.rect_position.x -= diffText.rect_size.x / 2
	
	speedText.rect_position.x = scoreBG.rect_position.x - (scoreBG.rect_scale.x / 2)
	speedText.rect_position.x -= speedText.rect_size.x / 2

func _on_AddNewSong_pressed():
	songUtil.visible = !songUtil.visible

func _on_AddDiff_pressed():
	var d = $SongUtil/DifficultyName.text
	if d != "" and not songMakerDifficultyList.has(d):
		songMakerDifficultyList.append(d)
		
		var dt = $SongUtil/Difficulties
		dt.text = "Difficulties:\n"
		for diff in songMakerDifficultyList:
			dt.text += diff + "\n"
		
func _on_RemoveDiff_pressed():
	var d = $SongUtil/DifficultyName.text
	if d != "" and songMakerDifficultyList.has(d):
		songMakerDifficultyList.erase(d)
		
		var dt = $SongUtil/Difficulties
		dt.text = "Difficulties:\n"
		for diff in songMakerDifficultyList:
			dt.text += diff + "\n"

func _on_ActuallyAddSong_pressed():
	var sn = $SongUtil/SongName.text
	var ci = $SongUtil/CharacterIcon.text
	var bc = $SongUtil/BGColor.text
	
	if sn != "" and ci != "" and songMakerDifficultyList.size() > 0:
		var diffs = ""
		var i:int = 0
		for d in songMakerDifficultyList:
			var comma = ","
			if i == songMakerDifficultyList.size() - 1:
				comma = ""
			diffs += d + comma
			i += 1
			
		var finalData:String = sn + ':' + ci + ':' + bc + ':' + diffs + "\n"
		print("SAVING FINAL DATA TO res://assets/data/freeplaySongs.txt!!")
		
		var f = File.new()
		var error = f.open(Paths.txt("data/freeplaySongs"), File.READ_WRITE)
		if error == OK:
			f.seek_end()
			f.store_string(finalData)
			f.close()
			
			print("SAVED SUCCESSFULLY.")
		else:
			print("SAVING FAILED.")
