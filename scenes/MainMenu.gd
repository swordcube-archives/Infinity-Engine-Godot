extends Node2D

onready var camera = $Camera2D

var curSelected:int = 0
var items:Array = []

func _ready():
	for item in $ParallaxBackground/layer2.get_children():
		items.append(item)
		
	changeSelection()
	
func _input(event):
	if Input.is_action_just_pressed("ui_up"):
		changeSelection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		changeSelection(1)
		
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
