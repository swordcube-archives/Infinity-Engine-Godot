extends Node

var defaultSaveData:Dictionary = {}

# SCORES
func getScore(week:String, diff:String):
	if saveData.has(week + "-" + diff):
		return saveData[week + "-" + diff]
	else:
		saveData[week + "-" + diff] = 0
		flushData()
		return saveData[week + "-" + diff]

	return null
	
func setScore(week:String, diff:String, value:int = 0):
	saveData[week + "-" + diff] = value
	flushData()
	
# DON'T MODIFY THIS SHIT!

var saveData = {}

var saveDataPath = "user://highscore.save"

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
					print(thing + " NOT IN SCORE SAVE DATA, PUTTING IT IN SCORE SAVE DATA!")
					saveData[thing] = defaultSaveData[thing]
				
			if doFlush:	
				print("WRITING SCORE SAVE DATA BECAUSE IT WAS CHANGED!")
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
