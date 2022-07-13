extends Node

# MODIFY THIS! DON'T TOUCH ANYTHING ELSE!!
var defaultSaveData:Dictionary = {
	# Gameplay Modifiers
	"botplay": false,
	"play-as-opponent": false,
	"health-drain": 0.0,
	"hp-gain-multiplier": 1,
	"hp-loss-multiplier": 1,
	"scroll-speed-type": "Multiplicative",
	"scroll-speed": 1,
	
	# Keybinds
	"binds_1": ["SPACE"],
	"binds_2": ["D", "K"],
	"binds_3": ["D", "SPACE", "K"],
	"binds_4": ["D", "F", "J", "K"],

	"binds_5": ["D", "F", "SPACE", "J", "K"],

	"binds_6": ["S", "D", "F", "J", "K", "L"],
	"binds_7": ["S", "D", "F", "SPACE", "J", "K", "L"],
	"binds_8": ["A", "S", "D", "F", "H", "J", "K", "L"],
	"binds_9": ["A", "S", "D", "F", "SPACE", "H", "J", "K", "L"],
	
	# Everything else
	"mods": {},
	"volume": 9,
	"muted": false,
	"downscroll": false,
	"centered-notes": false,
	"ghost-tapping": true,
	"hitsound": "None",
	"note-splashes": true,
	"fps-counter": true,
	"stage-opacity": 1,
	"keybind-reminders": true,
	"vsync": false,
	"clip-style": "FNF",
	"ultra-performance": false,
	"note-offset": 0.0,
	"marvelous-timing": 40.75,
	"sick-timing": 43.5,
	"good-timing": 75.5,
	"bad-timing": 125,
	"shit-timing": 150,
	"ui-skin": "Arrows",
	"icon-bounce-style": "Default",
	"classic-health-bar": false,
	"rating-camera": "HUD",
}
# ^^^ MODIFY THIS!

func setupBinds():
	var binds = getOption("binds_" + str(PlayStateSettings.keyCount))
	
	for action_num in PlayStateSettings.keyCount:
		var action = "gameplay_" + str(action_num)
		
		var keys = InputMap.get_action_list(action)
		
		var new_Event = InputEventKey.new()
		# set key to the scancode of the key
		new_Event.set_scancode(OS.find_scancode_from_string(binds[action_num].to_lower()))
		
		if keys.size() - 1 != -1: # error handling shit
			InputMap.action_erase_event(action, keys[keys.size()-1])
		else:
			InputMap.add_action(action)
		
		InputMap.action_add_event(action, new_Event)

var gameVersion:String = "16622"
var wentThruTitle:bool = false

func _ready():
	gameVersion = CoolUtil.getTXT(Paths.txt("data/gameVersionDate"))[0]
	Discord.init()
	
	if get_tree().current_scene.name != "TitleScreen":
		wentThruTitle = true
		
	yield(get_tree().create_timer(0.1),"timeout")
	OS.vsync_enabled = getOption("vsync")
	setupBinds()

# USE THIS TO GET OPTIONS AND SET OPTIONS
func getOption(option:String):
	if saveData.has(option):
		return saveData[option]
	else:
		saveData[option] = defaultSaveData[option]
		flushData()

	return null
	
func setOption(option:String, value):
	saveData[option] = value
	flushData()
	
# DON'T MODIFY THIS SHIT!

var saveData = {}

var saveDataPath = "user://preferences.save"

func _init():
	var file = File.new()
	if file.file_exists(saveDataPath):
		var error = file.open(saveDataPath, File.READ)
		if error == OK:
			saveData = file.get_var()
			
			var doFlush:bool = false
			for thing in defaultSaveData.keys():
				if not thing in saveData.keys():
					doFlush = true
					print(thing + " NOT IN SAVE DATA, PUTTING IT IN SAVE DATA!")
					saveData[thing] = defaultSaveData[thing]
				
			if doFlush:	
				print("WRITING SAVE DATA BECAUSE IT WAS CHANGED!")
				flushData()
	else:
		saveData = defaultSaveData
		flushData()

func flushData():
	var file = File.new()
	var error = file.open(saveDataPath, File.WRITE)
	if error == OK:
		file.store_var(saveData)
		file.close()
