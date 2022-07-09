extends Node

var mods:PoolStringArray = []
var modScenes:Dictionary = {}

func _ready():
	loadMods()
	
func loadMods(replaceFiles:bool = true):
	mods = []
	modScenes.clear()
	ProjectSettings.load_resource_pack("Infinity Engine.pck", true)
	
	var d = Directory.new()
	if d.dir_exists("user://mods"):
		var fileList:Array = CoolUtil.listFilesInDirectory("user://mods")
		for file in fileList:
			if file.ends_with(".pck"):
				mods.append(file.split(".pck")[0])
				# load mod if it exists in save data and if it's enabled
				if Preferences.getOption("mods").has(file.split(".pck")[0]):
					if Preferences.getOption("mods")[file.split(".pck")[0]] == true:
						print("MOD EXISTS IN SAVE DATA! LOADING IT!")
						ProjectSettings.load_resource_pack("user://mods/" + file.split(".pck")[0], replaceFiles)
						modScenes[file.split(".pck")[0]] = load("res://scenes/misc/Mod.tscn").instance()
				else:
					# put mod in save data if it doesn't exist there and load it
					print("MOD DOESN'T EXIST IN SAVE DATA!, PUTTING IT THERE AND LOADING IT!")
					var modsCopy:Dictionary = Preferences.getOption("mods").duplicate()
					modsCopy[file.split(".pck")[0]] = true
					Preferences.setOption("mods", modsCopy)
					ProjectSettings.load_resource_pack("user://mods/" + file.split(".pck")[0], replaceFiles)
					modScenes[file.split(".pck")[0]] = load("res://scenes/misc/Mod.tscn").instance()
	else:
		print("Mods directory doesn't exist! Creating one rn...")
		d.make_dir("user://mods")
		loadMods()
		
func loadSpecificMod(mod, loadBase:bool = true, replaceFiles:bool = true):
	if loadBase:
		ProjectSettings.load_resource_pack("Infinity Engine.pck", true)
	
	if Preferences.getOption("mods").has(mod) and Preferences.getOption("mods")[mod] == true:
		ProjectSettings.load_resource_pack("user://mods/"+mod+".pck", replaceFiles)
		modScenes[mod] = load("res://scenes/misc/Mod.tscn").instance()
		
func loadSpecificModForce(mod, loadBase:bool = true, replaceFiles:bool = true):
	if loadBase:
		ProjectSettings.load_resource_pack("Infinity Engine.pck", true)
	
	if Preferences.getOption("mods").has(mod):
		ProjectSettings.load_resource_pack("user://mods/"+mod+".pck", replaceFiles)
		modScenes[mod] = load("res://scenes/misc/Mod.tscn").instance()
