extends Node

# default save values
var og_save = {}

var save = {}

var save_file = File.new()

func _ready():
	if save_file.file_exists("user://WeekHighscore.json"):
		save_file.open("user://WeekHighscore.json", File.READ)
		save = JSON.parse(save_file.get_as_text()).result
	else:
		save_file.open("user://WeekHighscore.json", File.WRITE)
		save_file.store_line(to_json(og_save))
	
	save_file.close()

func save_dict():
	return save

func get_score(data):
	if not save.has(data):
		set_score(data, 0)
		
	return save[data]

func set_score(data, value):
	save[data] = value
	
	save_file.open("user://WeekHighscore.json", File.WRITE)
	save_file.store_line(to_json(save))
	
	save_file.close()
