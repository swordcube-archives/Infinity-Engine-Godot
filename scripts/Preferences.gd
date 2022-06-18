extends Node

# MODIFY THIS! DON'T TOUCH ANYTHING ELSE!!
var defaultSaveData:Dictionary = {
	"mods": {},
	"volume": 9,
	"muted": false,
	"downscroll": false,
	"middlescroll": false,
	"custom-scroll-speed": false,
	"scroll-speed": 0,
	"note-offset": 0,
	"ui-skin": "Arrows",
	"icon-bounce-style": "Default",
	"classic-health-bar": false,
}
# ^^^ MODIFY THIS!

var gameVersion:String = "16622"
var wentThruTitle:bool = false

func _ready():
	if get_tree().current_scene.name != "TitleScreen":
		wentThruTitle = true

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