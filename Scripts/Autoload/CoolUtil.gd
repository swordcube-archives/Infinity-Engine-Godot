extends Node

var engine_version = "1.0.0a"

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
	var data_file = File.new()
	if data_file.open(path, File.READ) != OK:
		print("TXT DOESN'T EXIST!")
		return null
		
	var data_text = data_file.get_as_text()
	data_file.close()
		
	return data_file

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
