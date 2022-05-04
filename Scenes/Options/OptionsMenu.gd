extends Node2D

var curSelected = 0

func _ready():
	change_selection(0)

func _process(delta):
	if Input.is_action_just_pressed("ui_back"):
		SceneManager.switch_scene("MainMenu")
		
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
						"Optimization", # title
						"optimization", # actual thing in save data
						"Gets rid of all characters and stages for performance.", # desc
						"bool", # type
					],
					[
						"Ghost Tapping", # title
						"ghost-tapping", # actual thing in save data
						"When enabled, pressing notes that don't exist won't give you a miss.", # desc
						"bool", # type
					],
					[
						"Pussy Mode", # title
						"pussy-mode", # actual thing in save data
						"enables shit like gaining health from sustains.\nif you enable this you're a pussy lmao", # desc
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
						"Strum Animations", # title
						"strum-animations", # actual thing in save data
						"When disabled, the strums stay static.", # desc
						"bool", # type
					],
					[
						"Enable Retry Button", # title
						"enable-retry-button", # actual thing in save data
						"When enabled, pressing R will insta-kill you.", # desc
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
						"Scroll Speed", # title
						"scroll-speed", # actual thing in save data
						"Change how fast your notes scroll!\nScroll Type is how speed is applied.", # desc
						"float", # type
						0.1, # multiplier
						[0, 10], # min and max
						1, # decimals to display
					],
					[
						"Scroll Type", # title
						"scroll-type", # actual thing in save data
						"Multiplicative = Adds to the song's scroll speed | Constant = One speed for every song", # desc
						"string", # type
						["Multiplicative", "Constant"],
					],
					[
						"Hitsound", # title
						"hitsound", # actual thing in save data
						"Make notes do funny sound when hit", # desc
						"string", # type
						["None", "osu!", "Dave and Bambi", "Vine Boom", "Generic"],
					],
					[
						"Note Splashes", # title
						"note-splashes", # actual thing in save data
						'When enabled, The game will play a firework-like effect when you hit a note and get a "SiCK!!"', # desc
						"bool", # type
					],
					[
						"Memory Leaks", # title
						"memory-leaks", # actual thing in save data
						'loads literally everything in the game at once lol\nturn off to unleak your memory', # desc
						"bool", # type
					],
					[
						"UI Skin", # title
						"ui-skin", # actual thing in save data
						"Change how everything looks with a new skin!", # desc
						"string", # type
						["Default", "Circles"], # values
					],
					[
						"Sick Timing", # title
						"sick-timing", # actual thing in save data
						'Change how much milliseconds it takes to get a "SiCK!!"', # desc
						"float", # type
						0.1, # multiplier
						[-200, 200], # min and max
						1, # decimals to display
					],
					[
						"Good Timing", # title
						"good-timing", # actual thing in save data
						'Change how much milliseconds it takes to get a "Good!"', # desc
						"float", # type
						0.1, # multiplier
						[-200, 200], # min and max
						1, # decimals to display
					],
					[
						"Bad Timing", # title
						"bad-timing", # actual thing in save data
						'Change how much milliseconds it takes to get a "Bad"', # desc
						"float", # type
						0.1, # multiplier
						[-200, 200], # min and max
						1, # decimals to display
					],
					[
						"Shit Timing", # title
						"shit-timing", # actual thing in save data
						'Change how much milliseconds it takes to get a "SHiT"', # desc
						"float", # type
						0.1, # multiplier
						[-200, 200], # min and max
						1, # decimals to display
					],
				]
				SceneManager.switch_scene("Options/BaseOptionsMenu", false)
			"Controls":
				SceneManager.switch_scene("Options/ControlsMenu", false)
			"Exit":
				SceneManager.switch_scene("MainMenu")
			
		
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
