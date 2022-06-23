extends Node2D

class_name HealthBar

onready var bar:ProgressBar = $ProgressBar

onready var iconP2:Sprite = $iconP2
onready var iconP1:Sprite = $iconP1

onready var scoreTxt:Label = $scoreTxt

onready var PlayState = $"../../../"

var health:float = 1.0
var minHealth:float = 0.0
var maxHealth:float = 2.0

var percent:int = 0

func _ready():
	Conductor.connect("beatHit", self, "beatHit")
	
	match Preferences.getOption("icon-bounce-style"):
		"Psych":
			iconP2.offset.y = 0
			iconP1.offset.y = 0
			
			iconP2.position.y += 75
			iconP1.position.y += 75
			
	updateText()
	
func calculateAccuracy():
	if PlayState.totalNotes > 0 and PlayState.totalHit > 0.0:
		PlayState.songAccuracy = (PlayState.totalHit / PlayState.totalNotes)
	else:
		PlayState.songAccuracy = 0
			
func updateText():
	calculateAccuracy()
	
	var botplayWarning:String = ""
	if PlayStateSettings.botPlay:
		botplayWarning = " // BOTPLAY"
	
	scoreTxt.text = (
		"Score: " + str(PlayState.songScore) + " // " +
		"Misses: " + str(PlayState.songMisses) + " // " +
		"Accuracy: " + str(MathUtil.roundDecimal(PlayState.songAccuracy * 100, 2)) + "% // " +
		"Rank: " + Ranking.getRank(MathUtil.roundDecimal(PlayState.songAccuracy * 100, 2)) +
		botplayWarning
	)
	
func beatHit():
	iconP2.scale = Vector2(1.2, 1.2)
	iconP1.scale = Vector2(1.2, 1.2)
	positionIcons()
	
const greenHealth:StyleBoxFlat = preload("res://scenes/ui/playState/healthBar/greenHealth.tres")
const redHealth:StyleBoxFlat = preload("res://scenes/ui/playState/healthBar/redHealth.tres")

func _process(delta):
	bar.min_value = minHealth
	bar.max_value = maxHealth
	bar.value = health
	percent = (bar.value / 2) * 100.0
	
	if not Preferences.getOption("play-as-opponent"):
		if PlayState.dad:
			if Preferences.getOption("classic-health-bar"):
				greenHealth.bg_color = Color.green
			else:
				greenHealth.bg_color = PlayState.bf.healthColor
			iconP2.texture = PlayState.dad.healthIcon
			
		if PlayState.bf:
			if Preferences.getOption("classic-health-bar"):
				redHealth.bg_color = Color.red
			else:
				redHealth.bg_color = PlayState.dad.healthColor
			iconP1.texture = PlayState.bf.healthIcon
	else:
		if PlayState.bf:
			if Preferences.getOption("classic-health-bar"):
				greenHealth.bg_color = Color.red
			else:
				greenHealth.bg_color = PlayState.dad.healthColor
			iconP2.texture = PlayState.bf.healthIcon
			
		if PlayState.dad:
			if Preferences.getOption("classic-health-bar"):
				redHealth.bg_color = Color.green
			else:
				redHealth.bg_color = PlayState.bf.healthColor
			iconP1.texture = PlayState.dad.healthIcon

	if percent <= 20:
		iconP2.switchTo("winning")
		iconP1.switchTo("losing")
	else:
		iconP2.switchTo("normal")
		iconP1.switchTo("normal")
		
	if percent >= 80:
		iconP2.switchTo("losing")
		iconP1.switchTo("winning")
	
	iconP2.scale = lerp(iconP2.scale, Vector2.ONE, MathUtil.getLerpValue(0.2, delta))
	iconP1.scale = iconP2.scale
	
	positionIcons()
	
func positionIcons():
	var iconOffset:int = 26
	iconP1.position.x = -(bar.rect_size.x / 2.7) + (bar.rect_size.x * (MathUtil.remapToRange(percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset
	iconP2.position.x = -(bar.rect_size.x / 2.7) + (bar.rect_size.x * (MathUtil.remapToRange(percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2
