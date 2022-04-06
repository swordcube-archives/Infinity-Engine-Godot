extends Node2D

var curSelected = 0

func _ready():
	$Misc/Transition._fade_out()
	
	change_selection(0)

func _process(delta):
	if Input.is_action_just_pressed("ui_back"):
		$Misc/Transition.transition_to_scene("MainMenu")
		
	if Input.is_action_just_pressed("ui_up"):
		change_selection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		change_selection(1)
		
	if Input.is_action_just_pressed("ui_accept"):
		match($Options.get_children()[curSelected].name):
			"Preferences":
				OptionsMenuShit.cur_options = [
					[
						"Downscroll", # title
						"downscroll", # actual thing in save data
						"Makes your notes scroll downwards instead of upwards.", # desc
						"bool", # type
					],
					[
						"Middlescroll", # title
						"middlescroll", # actual thing in save data
						"Makes your notes centered on-screen.", # desc
						"bool", # type
					],
					[
						"Note Offset", # title
						"note-offset", # actual thing in save data
						"Change how late or early your notes spawn.\nNegative = Earlier - Positive = Later", # desc
						"float", # type
						0.1, # multiplier
						[-1000, 1000], # min and max
						1, # decimals to display
					],
					[
						"Botplay", # title
						"botplay", # actual thing in save data
						"When enabled, the game plays itself for you.", # desc
						"bool", # type
					],
					[
						"VSync", # title
						"vsync", # actual thing in save data
						"When enabled, the game limits the FPS to your monitor's refresh rate.", # desc
						"bool", # type
					],
					[
						"Keybind Reminders", # title
						"keybind-reminders", # actual thing in save data
						"When enabled, The game will tell you what your keybinds are when a song starts.", # desc
						"bool", # type
					],
					[
						"Hitsound", # title
						"hitsound", # actual thing in save data
						"Make notes do funny sound when hit", # desc
						"string", # type
						["None", "osu!", "Dave and Bambi", "Vine Boom"],
					],
					[
						"Note Splashes", # title
						"note-splashes", # actual thing in save data
						'When enabled, The game will play a firework-like effect when you hit a note and get a "SiCK!!"', # desc
						"bool", # type
					],
					[
						"UI Skin", # title
						"ui-skin", # actual thing in save data
						"Change how everything looks with a new skin!", # desc
						"string", # type
						["Default", "Circles"], # values
					]
				]
				$Misc/Transition.transition_to_scene("Options/BaseOptionsMenu")
			"Controls":
				$Misc/Transition.transition_to_scene("Options/ControlsMenu")
			"Exit":
				$Misc/Transition.transition_to_scene("MainMenu")
			
		
func change_selection(amount):
	AudioHandler.play_audio("scrollMenu")
	
	curSelected += amount
	if curSelected < 0:
		curSelected = $Options.get_child_count() - 1
	if curSelected > $Options.get_child_count() - 1:
		curSelected = 0
		
	var option_i = 0
	for option in $Options.get_children():
		option.modulate.a = 0.6
		if curSelected == option_i:
			option.modulate.a = 1
		
		option_i += 1
