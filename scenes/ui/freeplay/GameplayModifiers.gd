extends Node2D

var curSelected:int = 0

onready var options = $Options

func _ready():
	for j in options.get_child_count():
		var newOption:Node2D = options.get_child(j)
		newOption.position.x = (10 * j) + 30
		newOption.position.y = (70 * j) + 30
		newOption.isTool = false
		newOption.visible = true
		newOption.isMenuItem = true
		newOption.targetY = j
		var checkbox = newOption.get_node("Checkbox")
		if checkbox:
			checkbox.enabled = Preferences.getOption(newOption.saveDataOption)
			checkbox.refresh()
			
	changeSelection()
			
func _process(delta):
	if Input.is_action_just_pressed("ui_back"):
		get_tree().paused = false
		queue_free()
		
	if Input.is_action_just_pressed("ui_up"):
		changeSelection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		changeSelection(1)
		
func changeSelection(change:int = 0, doSound:bool = true):
	curSelected += change
	if curSelected < 0:
		curSelected = options.get_child_count() - 1
	if curSelected > options.get_child_count() - 1:
		curSelected = 0
		
	for i in options.get_child_count():
		var o = options.get_child(i)
		if curSelected == i:
			o.modulate.a = 1
		else:
			o.modulate.a = 0.6
		o.targetY = i - curSelected
		
	if doSound:
		AudioHandler.playSFX("scrollMenu")
