extends Node

var default_event_list = [["???", "No description"]]

var event_list = default_event_list

func init_event_list():
	event_list = default_event_list
	
	var files = Util.list_files_in_directory("res://Assets/Data/Events")
	
	for file in files:
		if not file.begins_with(".") and file.ends_with(".txt"):
			var event_name = file.split(".txt")[0]
			var event_desc = Util.get_txt(Paths.txt("Data/Events/" + event_name))
			event_list.append([event_name, event_desc])
