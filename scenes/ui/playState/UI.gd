extends Node2D

onready var PlayState = $"../../"

var opponentStrums:Node2D
var playerStrums:Node2D
var healthBar:Node2D

var ratingTemplate:Node2D = load("res://scenes/ui/playState/Rating.tscn").instance()

func _ready():
	var xMult:float = 315
	
	
			
	opponentStrums = load("res://scenes/ui/strums/4K.tscn").instance()
	opponentStrums.position.x = xMult
	opponentStrums.position.y = 100
	for strum in opponentStrums.get_children():
		strum.isOpponent = true
	add_child(opponentStrums)
	
	playerStrums = load("res://scenes/ui/strums/4K.tscn").instance()
	playerStrums.position.x = xMult + (CoolUtil.screenWidth / 2)
	playerStrums.position.y = 100
	add_child(playerStrums)
	
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
