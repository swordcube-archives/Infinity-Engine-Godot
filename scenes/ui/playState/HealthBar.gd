extends Node2D

class_name HealthBar

onready var bar:ProgressBar = $ProgressBar

onready var icons = $Icons # this is for animated icons

onready var iconP2 = $iconP2
onready var iconP1 = $iconP1

onready var scoreTxt:Label = $scoreTxt

onready var PlayState = $"../../../"

var health:float = 1.0
var minHealth:float = 0.0
var maxHealth:float = 2.0

var percent:int = 0

func _ready():
	Conductor.connect("beatHit", self, "beatHit")
			
	if not Preferences.getOption("play-as-opponent"):
		if PlayState.dad:
			var dadAnimIcon:String = "res://assets/images/icons/"+PlayState.dad.animatedHealthIconName+".tscn"
			print(dadAnimIcon+" exists")
			if ResourceLoader.exists(dadAnimIcon):
				print(dadAnimIcon+" exists")
				remove_child(iconP2)
				iconP2.queue_free()
				iconP2 = load(dadAnimIcon).instance()
				iconP2.position.y = -75
				icons.add_child(iconP2)
			
		if PlayState.bf:
			var bfAnimIcon:String = "res://assets/images/icons/"+PlayState.bf.animatedHealthIconName+".tscn"
			print(bfAnimIcon)
			if ResourceLoader.exists(bfAnimIcon):
				print(bfAnimIcon+" exists")
				remove_child(iconP1)
				iconP1.queue_free()
				iconP1 = load(bfAnimIcon).instance()
				iconP1.position.y = -75
				icons.add_child(iconP1)
				
				iconP1.spr.flip_h = true
	else:
		if PlayState.bf:
			var dadAnimIcon:String = "res://assets/images/icons/"+PlayState.bf.animatedHealthIconName+".tscn"
			print(dadAnimIcon)
			if ResourceLoader.exists(dadAnimIcon):
				print(dadAnimIcon+" exists")
				remove_child(iconP2)
				iconP2.queue_free()
				iconP2 = load(dadAnimIcon).instance()
				iconP2.position.y = -75
				icons.add_child(iconP2)
			
		if PlayState.dad:
			var bfAnimIcon:String = "res://assets/images/icons/"+PlayState.dad.animatedHealthIconName+".tscn"
			print(bfAnimIcon)
			if ResourceLoader.exists(bfAnimIcon):
				print(bfAnimIcon+" exists")
				remove_child(iconP1)
				iconP1.queue_free()
				iconP1 = load(bfAnimIcon).instance()
				iconP1.position.y = -75
				icons.add_child(iconP1)
				
				iconP1.spr.flip_h = true
			
	match Preferences.getOption("icon-bounce-style"):
		"Psych":
			if iconP2 is Sprite:
				iconP2.offset.y = 0
				iconP2.position.y += 75
			
			if iconP1 is Sprite:
				iconP1.offset.y = 0
				iconP1.position.y += 75
		_: # default icon type
			if iconP2 is Sprite:
				iconP2.offset.y = iconP2.texture.get_height()/2
				iconP2.position.y = -iconP2.texture.get_height()/2
			else:
				iconP2.spr.offset.y = iconP2.spr.frames.get_frame(iconP2.spr.animation, iconP2.spr.frame).get_height()/2
				iconP2.position.y = -iconP2.spr.frames.get_frame(iconP2.spr.animation, iconP2.spr.frame).get_height()/2
			
			if iconP1 is Sprite:
				iconP1.offset.y = iconP1.texture.get_height()/2
				iconP1.position.y = -iconP1.texture.get_height()/2
			else:
				iconP1.spr.offset.y = iconP1.spr.frames.get_frame(iconP1.spr.animation, iconP1.spr.frame).get_height()/2
				iconP1.position.y = -iconP1.spr.frames.get_frame(iconP1.spr.animation, iconP1.spr.frame).get_height()/2
			
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
			if iconP2 is Sprite:
				iconP2.texture = PlayState.dad.healthIcon
			
		if PlayState.bf:
			if Preferences.getOption("classic-health-bar"):
				redHealth.bg_color = Color.red
			else:
				redHealth.bg_color = PlayState.dad.healthColor
			if iconP1 is Sprite:
				iconP1.texture = PlayState.bf.healthIcon
	else:
		if PlayState.bf:
			if Preferences.getOption("classic-health-bar"):
				greenHealth.bg_color = Color.red
			else:
				greenHealth.bg_color = PlayState.dad.healthColor
			if iconP2 is Sprite:
				iconP2.texture = PlayState.bf.healthIcon
			
		if PlayState.dad:
			if Preferences.getOption("classic-health-bar"):
				redHealth.bg_color = Color.green
			else:
				redHealth.bg_color = PlayState.bf.healthColor
			if iconP1 is Sprite:
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
