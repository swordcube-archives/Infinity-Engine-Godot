extends Node

func list_files_in_directory(path):
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

var timeout = 0

func sort_ascending(a, b):
	if a < b:
		return true
	return false

func get_txt(path):
	var text_array = []
	var f = File.new()
	if path.ends_with(".txt"):
		f.open(path, File.READ)
	else:
		f.open(path + ".txt", File.READ)
		
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

func round_decimal(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
func remap_to_range(value, start1, stop1, start2, stop2):
	return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1))
	
func format_time(seconds, show_ms):
	var timeString:String = str(int(seconds / 60)) + ":"
	var timeStringHelper:int = int(seconds) % 60;
	if (timeStringHelper < 10):
		timeString += "0"
		
	timeString += str(timeStringHelper)
	
	if (show_ms):
		timeString += ".";
		timeStringHelper = int((seconds - int(seconds)) * 100)
		if (timeStringHelper < 10):
			timeString += "0"

		timeString += str(timeStringHelper)

	return timeString

