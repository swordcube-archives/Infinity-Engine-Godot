extends Node

# default save values
var og_save = {
	# key bind bullshit
	"keybinds_1": ["SPACE"],
	"keybinds_2": ["D","K"],
	"keybinds_3": ["D", "SPACE", "K"],
	"keybinds_4": ["D", "F", "J", "K"],
	"keybinds_5": ["D", "F", "SPACE", "J", "K"],
	"keybinds_6": ["S", "D", "F", "J", "K", "L"],
	"keybinds_7": ["S", "D", "F", "SPACE", "J", "K", "L"],
	"keybinds_8": ["A", "S", "D", "F", "H", "J", "K", "L"],
	"keybinds_9": ["A", "S", "D", "F", "SPACE", "H", "J", "K", "L"],
	# the rest of the shit
	"downscroll": false,
	"middlescroll": false,
	"note-offset": 0,
	"botplay": false,
	"keybind-reminders": false,
	"optimization": false,
	"hitsound": "None",
	"note-splashes": true,
	"memory-leaks": false,
	"ghost-tapping": false,
	"pussy-mode": false,
	"ui-skin": "Default",
	"vsync": false,
	"rating-position": [760, 270],
	"active-mods": {},
	"achievements": {},
	"volume": 0,
	"muted": false,
	"scroll-speed": 0,
	"scroll-type": "Multiplicative"
}

var initialized = false

var save = {}

var save_file = File.new()

func _ready():
	if save_file.file_exists("user://Settings.json"):
		save_file.open("user://Settings.json", File.READ)
		save = JSON.parse(save_file.get_as_text()).result
	else:
		save_file.open("user://Settings.json", File.WRITE)
		save_file.store_line(to_json(og_save))
	
	for thing in og_save:
		if not thing in save:
			save[thing] = og_save[thing]
	
	save_file.close()
	
	OS.set_use_vsync(save["vsync"])
	initialized = true
	
	VolumeControl.init()

func save_dict():
	return save

func get_data(data):
	return save[data]

func set_data(data, value):
	save[data] = value
	
	save_file.open("user://Settings.json", File.WRITE)
	save_file.store_line(to_json(save))
	
	save_file.close()
