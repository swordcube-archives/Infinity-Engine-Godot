extends Node

func get_json(path):
	var file = File.new()
	if path.ends_with(".json"):
		file.open(path, File.READ)
	else:
		file.open(path + ".json", File.READ)
		
	var result = JSON.parse(file.get_as_text()).result
	file.close()
	return result
