extends Node

var engine_version = "1.0.0a"
var screen_res = Vector2(
	ProjectSettings.get_setting("display/window/size/width"),
	ProjectSettings.get_setting("display/window/size/height")
)

var memory_leak_shit:Array = []

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	if Options.get_data("memory-leaks"):
		leak_memory()

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
	
func get_filelist(scan_dir : String) -> Array:
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
			my_files += get_filelist(dir.get_current_dir() + "/" + file_name)
		else:
			my_files.append(dir.get_current_dir() + "/" + file_name)

		file_name = dir.get_next()

	return my_files
	
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
	
func leak_memory():
	leak_something("res://Assets")
	leak_something("res://Scenes")
	leak_something("res://Scripts")
	
func unleak_memory():
	memory_leak_shit.clear()
			
func leak_something(path):
	for asset_path in get_filelist(path):
		memory_leak_shit.push_back(load(asset_path))
	
func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
