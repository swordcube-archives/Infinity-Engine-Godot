extends Node2D

onready var characters = $Characters

onready var dad = $Characters/dad
onready var gf = $Characters/gf
onready var bf = $Characters/bf

onready var tracks = $Tracks/Label

onready var freakyMenu:AudioStreamPlayer = AudioHandler.get_node("Music/freakyMenu")

onready var weekTemplate = $WeekTemplate
onready var weeks = $Weeks

onready var scoreTxt = $scoreTxt

onready var difficultySprite = $DifficultySprite/Difficulty
onready var difficultyAnim = $DifficultyAnim

onready var diffArrows:Dictionary = {
	"left": $DifficultySprite/LeftArrow,
	"right": $DifficultySprite/RightArrow
}

var weekDifficulties:Dictionary = {}
var weekCharacters:Dictionary = {}
var weekSongs:Dictionary = {}
var weekTitles:Dictionary = {}
var diffTextures:Dictionary = {}
var preloadedCharacters:Dictionary = {}

var weekNames:PoolStringArray = []

var curSelected:int = 0
var curDifficulty:int = 1

var intendedScore:int = 0
var lerpScore:float = 0.0

func sortWeeks(a, b):
	if a.weekNum < b.weekNum:
		return true
		
	return false

func _ready():
	for file in CoolUtil.listFilesInDirectory("res://scenes/storymode/chars/"):
		if file.ends_with(".tscn"):
			preloadedCharacters[file.split(".tscn")[0]] = load("res://scenes/storymode/chars/"+file).instance()
			
	get_tree().paused = false
	AudioHandler.playMusic("freakyMenu")
	
	Conductor.changeBPM(102)
	Conductor.connect("beatHit",self,"beatHit")
	
	ModManager.loadMods()
	var weeksFolder:PoolStringArray = CoolUtil.listFilesInDirectory("res://assets/weeks")
	var funnyWeeks:Array = []
	var i:int = 0
	for item in weeksFolder:
		if item.ends_with(".json"):
			# load json
			var json = CoolUtil.getJSON("res://assets/weeks/"+item)
			json.rawName = item
			funnyWeeks.append(json)
			
		i += 1
		
	funnyWeeks.sort_custom(self, "sortWeeks")
		
	i = 0
	for json in funnyWeeks:
		# add characters and songs into dictonaries
		weekDifficulties[str(i)] = json.difficulties
		weekCharacters[str(i)] = json.characters
		weekSongs[str(i)] = json.songs
		weekTitles[str(i)] = json.weekTitle
		weekNames.append(json.rawName.split(".json")[0])
		# load difficulty images
		for diff in json.difficulties:
			if not diffTextures.has(diff):
				var diffTexPath:String = "res://assets/images/storydifficulties/"+diff+".png"
				if ResourceLoader.exists(diffTexPath):
					diffTextures[diff] = load(diffTexPath)
				else:
					diffTextures[diff] = CoolUtil.nullImage
		# adding the weeks
		var newWeek = weekTemplate.duplicate()
		newWeek.texture = Paths.loadTex(Paths.image("weeks/"+json.texture))
		newWeek.visible = true
		newWeek.position.x = 640
		newWeek.position.y = 500 + (109 * i)
		newWeek.targetY = i
		weeks.add_child(newWeek)
		
		i += 1
	
	Discord.update_presence("In the Story Menu")
	changeSelection()
	
	dad.dance()
	gf.dance()
	bf.dance()
	
	difficultyAnim.play("ding")
	
func _process(delta):
	if freakyMenu.playing:
		Conductor.songPosition = freakyMenu.get_playback_position() * 1000
	else:
		Conductor.songPosition += (delta * 1000)
		
	intendedScore = Highscore.getScore(weekNames[curSelected], weekDifficulties[str(curSelected)][curDifficulty])
	lerpScore = lerp(lerpScore, intendedScore, MathUtil.getLerpValue(0.35, delta))
	
	scoreTxt.text = "WEEK SCORE: "+str(abs(round(lerpScore)))
		
	dad.holdTimer = 0.0
	gf.holdTimer = 0.0
	bf.holdTimer = 0.0
	
func beatHit():
	if dad.isDancing():
		dad.dance()
	if gf.isDancing():
		gf.dance()
	if bf.isDancing():
		bf.dance()
	
var accepted:bool = false

func _input(event):
	if not accepted:
		if Input.is_action_just_pressed("ui_back"):
			Scenes.switchScene("MainMenu")
			AudioHandler.playSFX("cancelMenu")
			
		if Input.is_action_just_pressed("ui_up"):
			changeSelection(-1)
			
		if Input.is_action_just_pressed("ui_down"):
			changeSelection(1)
			
		if Input.is_action_just_pressed("ui_accept"):
			acceptWeek()
			
		# just pressed
			
		if Input.is_action_just_pressed("ui_left"):
			changeDifficulty(-1)
			diffArrows["left"].play("arrow push left")
			
		if Input.is_action_just_pressed("ui_right"):
			changeDifficulty(1)
			diffArrows["right"].play("arrow push right")
			
		# just released
		if Input.is_action_just_released("ui_left"):
			diffArrows["left"].play("arrow left")
			
		if Input.is_action_just_released("ui_right"):
			diffArrows["right"].play("arrow right")
			
func acceptWeek():
	AudioHandler.playSFX("confirmMenu")
	accepted = true
	bf.playAnim("hey")
	PlayStateSettings.songMultiplier = 1.0
	PlayStateSettings.storyMode = true
	PlayStateSettings.storyWeekName = weekNames[curSelected]
	PlayStateSettings.storyScore = 0
	PlayStateSettings.storyPlaylist = weekSongs[str(curSelected)].duplicate()
	PlayStateSettings.SONG = CoolUtil.getJSON(Paths.songJSON(PlayStateSettings.storyPlaylist[0], weekDifficulties[str(curSelected)][curDifficulty]))
	weeks.get_child(curSelected).flashing = true
	yield(get_tree().create_timer(1.5),"timeout")
	AudioHandler.stopMusic()
	weeks.get_child(curSelected).flashing = false
	Scenes.switchScene("PlayState")
	weeks.get_child(curSelected).flashing = false
		
func changeSelection(change:int = 0):
	curSelected += change
	if curSelected < 0:
		curSelected = weeks.get_child_count()-1
	if curSelected > weeks.get_child_count()-1:
		curSelected = 0
	
	var characters:Array = weekCharacters[str(curSelected)].duplicate()
	for i in characters.size():
		var item:String = characters[i]
		if item == "":
			characters[i] = "blank"
			
	var charSpacing:float = 350.0
		
	if dad.name != characters[0]:
		self.characters.remove_child(dad)
		dad.queue_free()
		dad = preloadedCharacters[characters[0]].duplicate()
		dad.position.y += 64
		dad.position.x += 234
		self.characters.add_child(dad)
		
	if bf.name != characters[1]:
		self.characters.remove_child(bf)
		bf.queue_free()
		bf = preloadedCharacters[characters[1]].duplicate()
		bf.position.y += 64
		bf.position.x += 234 + (1 * charSpacing)
		self.characters.add_child(bf)
	
	if gf.name != characters[2]:
		self.characters.remove_child(gf)
		gf.queue_free()
		gf = preloadedCharacters[characters[2]].duplicate()
		gf.position.y += 64
		gf.position.x += 234 + (2 * charSpacing)
		self.characters.add_child(gf)
		
	for i in weeks.get_child_count():
		var week = weeks.get_child(i)
		week.targetY = i-curSelected
		
	var tracks:PoolStringArray = weekSongs[str(curSelected)]
	self.tracks.text = tracks.join("\n")
	
	$weekTitleTxt.text = weekTitles[str(curSelected)]
	changeDifficulty()
		
	AudioHandler.playSFX("scrollMenu")
	
func changeDifficulty(change:int = 0):
	var oldDiff = curDifficulty
	curDifficulty += change
	if curDifficulty < 0:
		curDifficulty = weekDifficulties[str(curSelected)].size()-1
	if curDifficulty > weekDifficulties[str(curSelected)].size()-1:
		curDifficulty = 0
		
	if oldDiff != curDifficulty:
		difficultySprite.texture = diffTextures[weekDifficulties[str(curSelected)][curDifficulty]]
			
		difficultyAnim.seek(0.0)
		difficultyAnim.play("ding")
