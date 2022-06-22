extends Node2D

onready var pageTemplate = $PageTemplate
onready var pageOptions = $PageOptions

onready var pagesNode = $Pages

onready var options = $Options

onready var strip = $Strip
onready var pageArrows = $Label

var selectingPage:bool = false

var curPage:int = 0
var curSelected:int = 0

func _ready():
	get_tree().paused = false
	AudioHandler.playMusic("optionsMenu")
	
	for i in pagesNode.get_child_count():
		var newPage = pageTemplate.duplicate()
		newPage.visible = true
		newPage.targetX = i
		newPage.get_node("Label").text = pagesNode.get_child(i).name
		pageOptions.add_child(newPage)
		
	changePage()
	
func _process(delta):
	$Description.text = options.get_child(curSelected).optionDescription
	$Description.rect_size.y = 0
	$DescriptionBox.rect_size.y = $Description.rect_size.y + 30
	$DescriptionBox.rect_position.y = CoolUtil.screenHeight - (($Strip.rect_size.y + $DescriptionBox.rect_size.y) + 10)
	$Description.rect_position.y = $DescriptionBox.rect_position.y + 10
		
func _input(event):
	if Input.is_action_just_pressed("ui_back"):
		if PlayStateSettings.goBackToOptionsFromPause:
			PlayStateSettings.goBackToOptionsFromPause = false
			Scenes.switchScene("PlayState")
			AudioHandler.stopMusic()
		else:
			Scenes.switchScene("MainMenu")
			AudioHandler.playMusic("freakyMenu")
		
	if Input.is_action_just_pressed("ui_focus_next"):
		selectingPage = not selectingPage
		
	if selectingPage:
		options.modulate.a = 0.35
		strip.color.a = 0.75
		pageArrows.modulate.a = 0.45
		pageOptions.modulate.a = 1
		if Input.is_action_just_pressed("ui_left"):
			changePage(-1)
			
		if Input.is_action_just_pressed("ui_right"):
			changePage(1)
	else:
		options.modulate.a = 1
		strip.color.a = 0.75/3
		pageArrows.modulate.a = 0.45/3
		pageOptions.modulate.a = 1*0.3
		
		if Input.is_action_just_pressed("ui_up"):
			changeSelection(-1)
			
		if Input.is_action_just_pressed("ui_down"):
			changeSelection(1)
		
func changePage(change:int = 0):
	curPage += change
	if curPage < 0:
		curPage = pagesNode.get_child_count() - 1
	if curPage > pagesNode.get_child_count() - 1:
		curPage = 0
		
	for i in pageOptions.get_child_count():
		pageOptions.get_child(i).targetX = i - curPage
		
	for o in options.get_children():
		options.remove_child(o)
		o.queue_free()
		
	for j in pagesNode.get_child(curPage).get_child_count():
		var newOption:Node2D = pagesNode.get_child(curPage).get_child(j).duplicate()
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
		options.add_child(newOption)
		
	curSelected = 0
	changeSelection()
	
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
