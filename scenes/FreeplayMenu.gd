extends Node2D

var songTemplate:FreeplaySong = load("res://scenes/ui/freeplay/SongTemplate.tscn").instance()

onready var bg = $BG
onready var songUtil = $SongUtil
onready var songs = $Songs

onready var scoreText = $ScoreText
onready var scoreBG = $ScoreBG
onready var diffText = $DiffText

var songMakerDifficultyList:Array = []

var songNames:Array = []
var songColors:Array = []
var songDifficulties:Array = []

var curSelected:int = 0
var curDifficulty:int = 0

func _ready():
	AudioHandler.playMusic("freakyMenu")
	
	if not OS.is_debug_build():
		$AddNewSong.visible = false
		
	songUtil.visible = false
	
	var txt = CoolUtil.getTXT(Paths.txt("data/freeplaySongs"))
	var i:int = 0
	for item in txt:
		var split = item.split(":")
		if len(item) > 0:
			if OS.is_debug_build() or not (range(split.size()).has(4) and split[4] == "DEBUG_ONLY"):
				songNames.append(split[0])
				songColors.append(split[2])
				songDifficulties.append(split[3].split(","))
				
				var newSong:FreeplaySong = songTemplate.duplicate()
				newSong.position.x = (10 * i) + 30
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

func _process(delta):
	bg.modulate = lerp(bg.modulate, Color(songColors[curSelected]), MathUtil.getLerpValue(0.045, delta))
	
	scoreText.text = "PERSONAL BEST: " + str(Highscore.getScore(songNames[curSelected], songDifficulties[curSelected][curDifficulty]))
	positionHighscore()
	
	if not songUtil.visible:
		if Input.is_action_just_pressed("ui_back"):
			Scenes.switchScene("MainMenu")
			AudioHandler.playSFX("cancelMenu")
			
		if Input.is_action_just_pressed("ui_up"):
			changeSelection(-1)
			
		if Input.is_action_just_pressed("ui_down"):
			changeSelection(1)
			
		if Input.is_action_just_pressed("ui_left"):
			changeDifficulty(-1)
			
		if Input.is_action_just_pressed("ui_right"):
			changeDifficulty(1)
			
		if not AudioHandler.inst.playing and Input.is_action_just_pressed("ui_space"):
			AudioHandler.playInst(songNames[curSelected])
			AudioHandler.playVoices(songNames[curSelected])
		elif Input.is_action_just_pressed("ui_accept"):
			AudioHandler.stopMusic()
			PlayStateSettings.deaths = 0
			PlayStateSettings.practiceMode = false
			PlayStateSettings.usedPractice = false
			PlayStateSettings.availableDifficulties = songDifficulties[curSelected]
			PlayStateSettings.difficulty = songDifficulties[curSelected][curDifficulty]
			PlayStateSettings.SONG = CoolUtil.getJSON(Paths.songJSON(songNames[curSelected], PlayStateSettings.difficulty))
			Scenes.switchScene("PlayState")
		
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
			
func changeDifficulty(change:int = 0):
	curDifficulty += change
	if curDifficulty < 0:
		curDifficulty = songDifficulties[curSelected].size() - 1
	if curDifficulty > songDifficulties[curSelected].size() - 1:
		curDifficulty = 0
		
	diffText.text = "< "+songDifficulties[curSelected][curDifficulty].to_upper()+" >"	
	positionHighscore()
	
func positionHighscore():
	scoreText.rect_size.x = 0
	diffText.rect_size.x = 0
	
	scoreText.rect_position.x = CoolUtil.screenWidth - scoreText.rect_size.x - 6
	scoreBG.rect_scale.x = CoolUtil.screenWidth - scoreText.rect_position.x + 6
	scoreBG.rect_position.x = CoolUtil.screenWidth - scoreBG.rect_scale.x / 300
	diffText.rect_position.x = scoreBG.rect_position.x - (scoreBG.rect_scale.x / 2)
	diffText.rect_position.x -= diffText.rect_size.x / 2

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