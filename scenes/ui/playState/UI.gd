extends Node2D

onready var PlayState = $"../../"

var opponentStrums:Node2D
var playerStrums:Node2D
var healthBar:Node2D

var timeBar:Node2D

var ratingTemplate:Node2D = load("res://scenes/ui/playState/Rating.tscn").instance()

func _ready():
	var xMult:float = 315
			
	opponentStrums = load("res://scenes/ui/strums/4K.tscn").instance()
	opponentStrums.position.x = xMult
	opponentStrums.position.y = 100
	var i:int = 0
	for strum in opponentStrums.get_children():
		strum.isOpponent = true
		strum.noteData = i
		if Preferences.getOption("play-as-opponent"):
			strum.isOpponent = not strum.isOpponent
		i += 1
	add_child(opponentStrums)
	
	playerStrums = load("res://scenes/ui/strums/4K.tscn").instance()
	playerStrums.position.x = xMult + (CoolUtil.screenWidth / 2)
	playerStrums.position.y = 100
	i = 0
	for strum in playerStrums.get_children():
		strum.noteData = i
		if Preferences.getOption("play-as-opponent"):
			strum.isOpponent = not strum.isOpponent
		i += 1
	add_child(playerStrums)
	
	# centered notes
	if Preferences.getOption("centered-notes"):
		if Preferences.getOption("play-as-opponent"):
			opponentStrums.position.x = 640
			playerStrums.visible = false
		else:
			playerStrums.position.x = 640
			opponentStrums.visible = false
	
	healthBar = load(PlayStateSettings.currentUiSkin.health_bar_path).instance()
	healthBar.position.x = CoolUtil.screenWidth / 2
	healthBar.position.y = CoolUtil.screenHeight * 0.9
	if PlayStateSettings.downScroll:
		healthBar.position.y = 70
	add_child(healthBar)
	
	if PlayStateSettings.downScroll:
		opponentStrums.position.y = 620
		playerStrums.position.y = 620
		
func _process(delta):
	healthBar.health = PlayState.health
