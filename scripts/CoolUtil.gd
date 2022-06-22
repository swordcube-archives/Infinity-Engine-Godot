extends Node

var nullRes = load("res://assets/images/null.res")

var screenWidth = ProjectSettings.get_setting("display/window/size/width")
var screenHeight = ProjectSettings.get_setting("display/window/size/height")

const singAnims:Dictionary = {
	1: ["singUP"],
	2: ["singLEFT", "singRIGHT"],
	3: ["singLEFT", "singUP", "singRIGHT"],
	4: ["singLEFT", "singDOWN", "singUP", "singRIGHT"],
	5: ["singLEFT", "singDOWN", "singUP", "singUP", "singRIGHT"],
	6: ["singLEFT", "singDOWN", "singRIGHT", "singLEFT", "singUP", "singRIGHT"],
	7: ["singLEFT", "singDOWN", "singRIGHT", "singUP", "singLEFT", "singUP", "singRIGHT"],
	8: ["singLEFT", "singDOWN", "singUP", "singRIGHT", "singLEFT", "singDOWN", "singUP", "singRIGHT"],
	9: ["singLEFT", "singDOWN", "singUP", "singRIGHT", "singUP", "singLEFT", "singDOWN", "singUP", "singRIGHT"],
}

func numToComboStr(num:int):
	var numStr:String = str(num)
	match len(numStr):
		1:
			numStr = "00" + numStr
		2:
			numStr = "0" + numStr
			
	return numStr
	
func getTXT(path):
	var text_array = []
	var timeout = 0
	
	var f = File.new()
	if f.open(path, File.READ) != OK:
		f.close()
		print("TXT DOESN'T EXIST!")
		return null
		
	var index = 1
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		text_array.append(line)

		index += 1
		timeout += 1
		
		if line != "" and line != "null":
			timeout = 0
		
		# if the file doesn't exist or has no contents
		# then we cancel
		if timeout >= 404:
			break
			
	f.close()
	return text_array
	
func getSizeLabel(num:int):
	var size:float = num
	var data = 0
	var dataTexts = ["b", "kb", "mb", "gb", "tb", "pb"]
	while size > 1024 and data < dataTexts.size() - 1:
		data += 1
		size = size / 1024
		
	size = round(size * 100) / 100
	return str(size) + dataTexts[data]
	
func getJSON(path):
	var data_file = File.new()
	if data_file.open(path, File.READ) != OK:
		print("JSON DOESN'T EXIST!")
		return null
		
	var data_text = data_file.get_as_text()
	data_file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		print("")
		return null
	else:
		return data_parse.result
		
	return null
	
func listFilesInDirectory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)

	dir.list_dir_end()

	return files
	
func getFileList(scan_dir : String) -> Array:
	var my_files : Array = []
	var dir := Directory.new()
	
	if dir.open(scan_dir) != OK:
		printerr("Warning: could not open directory: ", scan_dir)
		return []

	if dir.list_dir_begin(true, true) != OK:
		printerr("Warning: could not list contents of: ", scan_dir)
		return []

	var file_name := dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir():
			my_files += getFileList(dir.get_current_dir() + "/" + file_name)
		else:
			my_files.append(dir.get_current_dir() + "/" + file_name)

		file_name = dir.get_next()

	return my_files
	
func formatTime(seconds, showMS = false):
	var timeString:String = str(int(seconds / 60)) + ":"
	var timeStringHelper:int = int(seconds) % 60
	if timeStringHelper < 10:
		timeString += "0"
		
	timeString += str(timeStringHelper)
	
	if showMS:
		timeString += ".";
		timeStringHelper = int((seconds - int(seconds)) * 100)
		if (timeStringHelper < 10):
			timeString += "0"

		timeString += str(timeStringHelper)

	return timeString
