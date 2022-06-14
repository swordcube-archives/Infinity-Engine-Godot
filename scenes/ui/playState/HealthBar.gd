extends Node2D

onready var bar1:ColorRect = $bar1
onready var bar2:ColorRect = $bar2

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
	scoreTxt.text = (
		"Score: " + str(PlayState.songScore) + " // " +
		"Misses: " + str(PlayState.songMisses) + " // " +
		"Accuracy: " + str(MathUtil.roundDecimal(PlayState.songAccuracy * 100, 2)) + "% // " +
		"Rank: " + Ranking.getRank(MathUtil.roundDecimal(PlayState.songAccuracy * 100, 2))
	)
	
func beatHit():
	iconP2.scale = Vector2(1.2, 1.2)
	iconP1.scale = Vector2(1.2, 1.2)

func _process(delta):
	percent = MathUtil.boundTo(health / 2, minHealth, maxHealth) * 100.0
	bar2.rect_scale.x = percent / 100.0
	
	iconP2.scale = lerp(Vector2.ONE, iconP2.scale, MathUtil.getLerpValue(0.8, delta))
	iconP1.scale = iconP2.scale
	
	var iconOffset:int = 26
	iconP1.position.x = -(bar1.rect_size.x / 2.75) + (bar1.rect_size.x * (MathUtil.remapToRange(percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset
	iconP2.position.x = -(bar1.rect_size.x / 2.75) + (bar1.rect_size.x * (MathUtil.remapToRange(percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2
