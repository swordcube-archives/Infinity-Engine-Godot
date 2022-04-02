extends Node

func get_json(path):
	var file = File.new()
	file.open(path + ".json", File.READ)
	return JSON.parse(file.get_as_text()).result
