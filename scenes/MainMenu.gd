extends Node2D

onready var magenta = $ParallaxBackground/layer1/Magenta

onready var camera = $Camera2D
onready var tween = $Tween

var curSelected:int = 0
var items:Array = []

func _ready():
	AudioHandler.playMusic("freakyMenu")
	
	get_tree().paused = false
	
	for item in $ParallaxBackground/layer2.get_children():
		items.append(item)
		
	magenta.flashValues.invert()
	changeSelection()
	
	$CanvasLayer/Label.text += " (" + CoolUtil.getTXT(Paths.txt("data/gameVersionDate"))[0] + ")"
	
var selectedSomethin:bool = false
	
func _input(event):
	# this is always available just in case the menu
	# softlocks itself
	if Input.is_action_just_pressed("ui_back"):
		Scenes.switchScene("TitleScreen")
		AudioHandler.playSFX("cancelMenu")
			
	if not selectedSomethin:
		if Input.is_action_just_pressed("ui_up"):
			changeSelection(-1)
			
		if Input.is_action_just_pressed("ui_down"):
			changeSelection(1)
			
		if Input.is_action_just_pressed("ui_accept"):
			selectedSomethin = true
			
			magenta.flashing = true
			
			AudioHandler.playSFX("confirmMenu")
			
			for i in items.size():
				if curSelected == i:
					items[i].flashing = true
				else:
					tween.interpolate_property(items[i], "modulate:a", 1, 0, 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.2)
					
			tween.start()
			
			yield(get_tree().create_timer(1.2), "timeout")
			items[curSelected].visible = false
			magenta.visible = false
			yield(get_tree().create_timer(0.2), "timeout")
			match items[curSelected].name:
				"story-mode":
					Scenes.switchScene("StoryMenu")
				"freeplay":
					Scenes.switchScene("FreeplayMenu")
				"mods":
					pass
				"options":
					pass
		
func changeSelection(change:int = 0):
	curSelected += change
	if curSelected < 0:
		curSelected = items.size() - 1
	if curSelected > items.size() - 1:
		curSelected = 0
		
	for i in items.size():
		if curSelected == i:
			items[i].play("white")
		else:
			items[i].play("basic")
			
	camera.position.y = items[curSelected].position.y - 150
	AudioHandler.playSFX("scrollMenu")
