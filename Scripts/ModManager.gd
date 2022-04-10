extends Node

var mods = []

var old_active_mods = {}

var active_mods = {}

var mod_instances = {}

func _ready():
	init_mods()
	
func init_mods():
	var files = Util.list_files_in_directory("user://")
		
	mods = []
	active_mods = Options.get_data("active-mods")
	
	ProjectSettings.load_resource_pack("InfinityEngineGodot.pck", true)
	
	for file in files:
		if not file.begins_with(".") and file.ends_with(".pck"):
			var file_name = file.split(".pck")[0]
			mods.append(file_name)
			
			if not active_mods.has(file_name):
				active_mods[file_name] = true
				
			var path = "user://" + file
				
			Options.set_data("active-mods", active_mods)
			
	for mod in mods:
		if get_active(mod):
			var path = "user://" + mod + ".pck"
			var success = ProjectSettings.load_resource_pack(path)
			
			if !success:
				print("MOD: " + mod + " FAILED TO LOAD!")
			else:
				var f = File.new()
				
				if f.file_exists("res://Scenes/Mods/" + mod + ".tscn"):
					var mod_data = load("res://Scenes/Mods/" + mod + ".tscn").instance()
					mod_instances[mod] = mod_data
				else:
					if f.file_exists("res://Scenes/Mods/Mod.tscn"):
						var mod_data = load("res://Scenes/Mods/Mod.tscn").instance()
						mod_instances[mod] = mod_data
					else:
						print("MOD: " + mod + " DOESN'T HAVE ANY DATA!")
			
	# remove non-existent mods
	for mod in active_mods:
		if not mods.has(mod):
			active_mods.erase(mod)
			Options.set_data("active-mods", active_mods)
			
	print("ALL MODS: " + str(mods))
	print("ACTIVE MODS: " + str(active_mods))
			
func get_active(mod):
	if not active_mods.has(mod):
		active_mods[mod] = false
		Options.set_data("active-mods", active_mods)
		
	return active_mods[mod]
	
func set_active(mod, value = true):
	active_mods[mod] = value
	Options.set_data("active-mods", active_mods)
		
	return active_mods[mod]
