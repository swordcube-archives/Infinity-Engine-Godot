extends Node

var achievements:Dictionary = {}
var unlocked:Dictionary = {}

func _ready():
	init_achievements()
	
func init_achievements():
	achievements = {}
	unlocked = Options.get_data("achievements")
	
	var origin = "res://Scenes/Achievements/AchievementList"
	var scenes = Util.list_files_in_directory(origin)
	
	for scene in scenes:
		if not scene.begins_with(".") and scene.ends_with(".tscn"):
			achievements[scene.split(".tscn")[0].to_lower()] = load(origin + "/" + scene).instance()
	
func unlock(achievement, force_show = false):
	if achievement in achievements:
		if not get_unlocked(achievement) or force_show:
			AchievementThingie.achievement_list.append(achievement.to_lower())
			set_unlocked(achievement)
	else:
		print("ACHIEVEMENT: " + achievement + " DOESN'T EXIST! CANNOT UNLOCK!")

func get_unlocked(achievement):
	if not achievement in unlocked:
		unlocked[achievement] = false
		Options.set_data("achievements", unlocked)
		
	return unlocked[achievement]
	
func set_unlocked(achievement, value = true):
	unlocked[achievement] = value
	Options.set_data("achievements", unlocked)
