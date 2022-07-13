extends Node2D

onready var PlayState = $"../../"

var opponentStrums:Node2D
var playerStrums:Node2D
var healthBar:Node2D

var timeBar:Node2D

var ratingTemplate:Node2D = load("res://scenes/ui/playState/Rating.tscn").instance()

var tween = Tween.new()

func create():
	add_child(tween)
	
	var xMult:float = 315
			
	opponentStrums = load("res://scenes/ui/strums/"+str(PlayStateSettings.keyCount)+"K.tscn").instance()
	opponentStrums.position.x = xMult
	opponentStrums.position.y = 100
	add_child(opponentStrums)
	var i:int = 0
	for strum in opponentStrums.get_children():
		strum.isOpponent = true
		strum.noteData = i
		if Preferences.getOption("play-as-opponent"):
			strum.isOpponent = not strum.isOpponent
		
			if not PlayStateSettings.botPlay and Preferences.getOption("keybind-reminders"):
				strum.keybind.text = Preferences.getOption("binds_"+str(PlayStateSettings.keyCount))[i]
				strum.keybind.visible = true
				tween.interpolate_property(strum.keybind, "modulate:a", 1, 0, 4,Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 4)
		i += 1
	
	playerStrums = load("res://scenes/ui/strums/"+str(PlayStateSettings.keyCount)+"K.tscn").instance()
	playerStrums.position.x = xMult + (CoolUtil.screenWidth / 2)
	playerStrums.position.y = 100
	add_child(playerStrums)
	i = 0
	for strum in playerStrums.get_children():
		strum.noteData = i
		if Preferences.getOption("play-as-opponent"):
			strum.isOpponent = not strum.isOpponent
		else:
			if not PlayStateSettings.botPlay and Preferences.getOption("keybind-reminders"):
				strum.keybind.text = Preferences.getOption("binds_"+str(PlayStateSettings.keyCount))[i]
				strum.keybind.visible = true
				tween.interpolate_property(strum.keybind, "modulate:a", 1, 0, 4,Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 4)
		i += 1
	
	tween.start()
	
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
		
func reloadHealthBar():
	remove_child(healthBar)
	healthBar.queue_free()
	
	healthBar = load(PlayStateSettings.currentUiSkin.health_bar_path).instance()
	healthBar.position.x = CoolUtil.screenWidth / 2
	healthBar.position.y = CoolUtil.screenHeight * 0.9
	if PlayStateSettings.downScroll:
		healthBar.position.y = 70
	add_child(healthBar)
		
func _process(delta):
	healthBar.health = PlayState.health
