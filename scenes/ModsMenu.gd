extends Node2D

onready var mods = $Mods

var modTemplate = preload("res://scenes/ui/modsMenu/ModThingie.tscn").instance()
var modsArray:PoolStringArray = []

var curSelected:int = 0

func _getDroppedFilesPath(files:PoolStringArray, screen:int) -> void:
	var mod_index = 0
	
	for file in files:
		var cool_file = File.new()
		cool_file.open(file, File.READ)
		
		var funny_array = cool_file.get_path_absolute().split("/", true)
		
		var new_dir = Directory.new()
		new_dir.copy(file, "user://mods/" + funny_array[len(funny_array) - 1])
	
	Scenes.switchScene("ModsMenu", true)
	ModManager.loadMods()

func _ready():
	get_tree().paused = false
	Discord.update_presence("In the Mods Menu")
	get_tree().connect("files_dropped", self, "_getDroppedFilesPath")
	
	AudioHandler.playMusic("freakyMenu")
	
	ModManager.modScenes.clear()
	modsArray = ModManager.mods
	
	$noMods.visible = modsArray.size() < 1
	
	for i in modsArray.size():
		var mod = modsArray[i]
		ModManager.loadSpecificModForce(mod)
		
		var newMod = modTemplate.duplicate()
		newMod.mod = mod
		newMod.isMenuItem = true
		newMod.targetY = i
		newMod.yAdd = 40
		mods.add_child(newMod)

		newMod.position.x = CoolUtil.screenWidth/2
		newMod.position.y = i * 200
		
		newMod.title.text = mod
		newMod.desc.text = ModManager.modScenes[mod].description
		newMod.icon.texture = load("res://assets/images/modIcon.png")
		
	changeSelection()
		
func _process(delta):
	if Input.is_action_just_pressed("ui_back"):
		AudioHandler.playSFX("cancelMenu")
		Scenes.switchScene("MainMenu")
		
	if Input.is_action_just_pressed("ui_up"):
		changeSelection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		changeSelection(1)
		
func changeSelection(change:int = 0):
	curSelected += change
	if curSelected < 0:
		curSelected = mods.get_child_count()-1
	if curSelected > mods.get_child_count()-1:
		curSelected = 0
	
	for i in mods.get_child_count():
		var m = mods.get_child(i)
		m.targetY = i-curSelected
		if curSelected == i:
			m.modulate.a = 1
		else:
			m.modulate.a = 0.6
		
	AudioHandler.playSFX("scrollMenu")
	if modsArray.size() > 0:
		Discord.update_presence("In the Mods Menu", "Selected: "+modsArray[curSelected])
