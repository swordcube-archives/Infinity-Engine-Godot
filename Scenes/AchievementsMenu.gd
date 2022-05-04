extends Node2D

var ach_shit = []
var curSelected = 0

func _ready():
	Achievements.init_achievements()
	spawn_achievements()
	change_selection(0)
	
func sort_ascending(a, b):
	if a.achievement_order < b.achievement_order:
		return true
		
	return false
	
func spawn_achievements():
	var index = 0
	for achievement in Achievements.achievements.values():
		ach_shit.append(achievement)
			
		index += 1
		
	ach_shit.sort_custom(self, "sort_ascending")

	index = 0
	print(ach_shit)
	for achievement in ach_shit:
		var is_template = achievement.internal_name == "template"
		var is_hidden = false
		if achievement.hidden:
			is_hidden = not Achievements.get_unlocked(achievement.internal_name)
		
		if not is_template and is_hidden == false:
			var newAch = $Template.duplicate()
			newAch.visible = true
			newAch.text = achievement.title
			newAch.name = achievement.internal_name
			newAch.rect_position.x += (20 * index)
			newAch.rect_position.y = 60 + (50 * index)
			newAch.achievement = achievement
			newAch.rect_size = Vector2(0, 0)
			
			$Achievements.add_child(newAch)
			
			var texture = load("res://Assets/Images/Achievements/" + achievement.internal_name + ".png")
			if texture == null:
				texture = load("res://Assets/Images/Achievements/unknown.png")
				
			if not Achievements.get_unlocked(achievement.internal_name):
				texture = load("res://Assets/Images/Achievements/locked.png")
				
			newAch.get_node("Icon").texture = texture
				
		index += 1
		
func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		change_selection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		change_selection(1)
		
	if Input.is_action_just_pressed("ui_back"):
		SceneManager.switch_scene("MainMenu")
		
	var index = 0
	for song in $Achievements.get_children():
		song.rect_position = lerp(song.rect_position, Vector2(240 + (20 * index) - (20 * curSelected), (350 + (160 * index)) - (160 * curSelected)), delta * 10)
		index += 1

func change_selection(amount):
	curSelected += amount
	
	if curSelected < 0:
		curSelected = $Achievements.get_child_count() - 1
		
	if curSelected > $Achievements.get_child_count() - 1:
		curSelected = 0
		
	var index = 0
	for song in $Achievements.get_children():
		if curSelected == index:
			song.modulate.a = 1
		else:
			song.modulate.a = 0.6
		index += 1
		
	AudioHandler.play_audio("scrollMenu")
