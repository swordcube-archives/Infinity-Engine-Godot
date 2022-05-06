extends Node

var engine_version = "1.0.0a"
var screen_res = Vector2(
	ProjectSettings.get_setting("display/window/size/width"),
	ProjectSettings.get_setting("display/window/size/height")
)

func get_json(path):
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
	
func get_txt(path):
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
	
func round_decimal(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

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
	
func format_time(seconds, show_ms = false):
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
	
func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
