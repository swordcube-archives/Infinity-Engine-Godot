extends Node2D

onready var keybind_menu = $KeybindMenu

onready var menu_template = $Bar/MenuTemplate
onready var menu_strip = $Bar

onready var bar = $Bar
onready var visible_menus = $Bar/Menus

onready var left_arrow = $LeftArrow
onready var right_arrow = $RightArrow

onready var visible_options = $Options

onready var tabnotif = $TabNotif

onready var desc_box = $DescriptionBox
onready var description = $DescriptionBox/Label

var menus:Array = [
	"Preferences",
	"Appearance",
	"Controls",
	"Adjust Offsets",
	"Misc"
]

var options:Dictionary = {
	"Preferences": [
		{
			"title": "Downscroll",
			"description": "Makes all notes scroll downwards instead of upwards.",
			"save_data_name": "downscroll",
			"type": "bool",
		},
		{
			"title": "Middlescroll",
			"description": "Makes all notes centered on-screen.",
			"save_data_name": "middlescroll",
			"type": "bool",
		},
		{
			"title": "Botplay",
			"description": "The game plays itself for you when enabled.\nScores will not be saved with Botplay enabled.",
			"save_data_name": "botplay",
			"type": "bool",
		},
		{
			"title": "Keybind Reminders",
			"description": "At the start of every song, You will be reminded\nwhat your keybinds are.",
			"save_data_name": "keybind-reminders",
			"type": "bool",
		},
		{
			"title": "Hitsound",
			"description": "Change what sound plays when hitting a note.",
			"save_data_name": "hitsound",
			"values": ["None", "osu!", "Dave and Bambi", "Vine Boom", "Generic"],
			"type": "string",
		},
		{
			"title": "Scroll Speed",
			"description": "Change how fast the notes go in a song.\n(PRESS LEFT & RIGHT to change)",
			"save_data_name": "scroll-speed",
			"multiplier": 0.1,
			"limits": [0, 10],
			"decimals": 1,
			"type": "float",
		},
		{
			"title": "Scroll Speed Type",
			"description": "Change how scroll speed is used in a song.\nMultiplicative = Adds onto the speed, Constant = Directly sets the speed.\n(PRESS LEFT & RIGHT to change)",
			"save_data_name": "scroll-type",
			"values": ["Multiplicative", "Constant"],
			"type": "string",
		},
		{
			"title": "Memory Leaks",
			"description": "Loads every image, sound, song, etc all at once.",
			"save_data_name": "memory-leaks",
			"type": "bool",
		},
		{
			"title": "Ghost Tapping",
			"description": "Allows you to press notes that don't exist when enabled.",
			"save_data_name": "ghost-tapping",
			"type": "bool",
		},
		{
			"title": "Pussy Mode",
			"description": "Disables anti-mash and allows gaining health from sustains.",
			"save_data_name": "pussy-mode",
			"type": "bool",
		},
		{
			"title": "Enable Insta-Kill Button",
			"description": "When enabled, pressing R will insta-kill you.\nDisable if this causes annoyance.",
			"save_data_name": "pussy-mode",
			"type": "bool",
		},
		{
			"title": "Go Back during Gameplay",
			"description": "When enabled, pressing BACKSPACE/ESCAPE will exit the song\n(without saving scores).",
			"save_data_name": "go-back-during-gameplay",
			"type": "bool",
		},
		{
			"title": "VSync",
			"description": "When enabled, The game will run at your monitors refresh rate.\nUsually 60hz or 120hz.",
			"save_data_name": "vsync",
			"type": "bool",
		},
		{
			"title": "Sick Timing",
			"description": 'Change the milliseconds required to get a "SiCK!!"\nNegative = Earlier, Positive = Later\n(PRESS LEFT & RIGHT to change)',
			"save_data_name": "sick-timing",
			"type": "float",
			"multiplier": 0.1,
			"limits": [0, 130],
			"decimals": 1,
		},
		{
			"title": "Good Timing",
			"description": 'Change the milliseconds required to get a "Good!"\nNegative = Earlier, Positive = Later\n(PRESS LEFT & RIGHT to change)',
			"save_data_name": "good-timing",
			"type": "float",
			"multiplier": 0.1,
			"limits": [0, 130],
			"decimals": 1,
		},
		{
			"title": "Bad Timing",
			"description": 'Change the milliseconds required to get a "Bad"\nNegative = Earlier, Positive = Later\n(PRESS LEFT & RIGHT to change)',
			"save_data_name": "bad-timing",
			"type": "float",
			"multiplier": 0.1,
			"limits": [0, 130],
			"decimals": 1,
		},
		{
			"title": "Shit Timing",
			"description": 'Change the milliseconds required to get a "SHIT"\nNegative = Earlier, Positive = Later\n(PRESS LEFT & RIGHT to change)',
			"save_data_name": "shit-timing",
			"type": "float",
			"multiplier": 0.1,
			"limits": [0, 130],
			"decimals": 1,
		},
	],
	
	"Appearance": [
		{
			"title": "Optimization",
			"description": "The stage and characters will not be loaded\nwhen enabled for extra performance.",
			"save_data_name": "optimization",
			"type": "bool",
		},
		{
			"title": "Note Splashes",
			"description": 'When enabled, a firework-like effect will play when\nyou hit a note and get a "SiCK!!" from it.',
			"save_data_name": "note-splashes",
			"type": "bool",
		},
		{
			"title": "UI Skin",
			"description": "Change how things like the arrows, countdown, and ratings look/sound.",
			"save_data_name": "ui-skin",
			"values": ["Default", "Circles"],
			"type": "string",
		},
	],
	
	"Controls": [
		{
			"title": "1k Keybind",
			"description": "Change the bind used for 1 key.\n(Press ACCEPT (ENTER/SPACE) to change)",
			"type": "menu",
		},
		{
			"title": "2k Keybinds",
			"description": "Change the keybinds used for 2 key.\n(Press ACCEPT (ENTER/SPACE) to change)",
			"type": "menu",
		},
		{
			"title": "3k Keybinds",
			"description": "Change the keybinds used for 3 key.\n(Press ACCEPT (ENTER/SPACE) to change)",
			"type": "menu",
		},
		{
			"title": "4k Keybinds",
			"description": "Change the keybinds used for 4 key.\n(Press ACCEPT (ENTER/SPACE) to change)",
			"type": "menu",
		},
		{
			"title": "5k Keybinds",
			"description": "Change the keybinds used for 5 key.\n(Press ACCEPT (ENTER/SPACE) to change)",
			"type": "menu",
		},
		{
			"title": "6k Keybinds",
			"description": "Change the keybinds used for 6 key.\n(Press ACCEPT (ENTER/SPACE) to change)",
			"type": "menu",
		},
		{
			"title": "7k Keybinds",
			"description": "Change the keybinds used for 7 key.\n(Press ACCEPT (ENTER/SPACE) to change)",
			"type": "menu",
		},
		{
			"title": "8k Keybinds",
			"description": "Change the keybinds used for 8 key.\n(Press ACCEPT (ENTER/SPACE) to change)",
			"type": "menu",
		},
		{
			"title": "9k Keybinds",
			"description": "Change the keybinds used for 9 key.\n(Press ACCEPT (ENTER/SPACE) to change)",
			"type": "menu",
		},
	],
	
	"Adjust Offsets": [
		{
			"title": "Note Offset",
			"description": "Change how early or late notes spawn.\nNegative = Earlier, Positive = Later\n(PRESS LEFT & RIGHT to change)",
			"save_data_name": "note-offset",
			"type": "float",
			"multiplier": 0.1,
			"limits": [-1000, 1000],
			"decimals": 1,
		},
		{
			"title": "Rating & Combo Offset",
			"description": "Change the positions of the Ratings & Combos.\n(Press ACCEPT (ENTER/SPACE) to change)",
			"type": "menu",
			"menu_to_load": "RatingOffsetMenu",
			"menu_category": "Options",
		},
	],
	
	"Misc": [
		{
			"title": "Tools Menu",
			"description": "Access a menu with useful tools like the\nChart Editor, XML Converter, etc.",
			"type": "menu",
			"menu_to_load": "ToolsMenu",
			"menu_category": "",
		},
	]
}

var option_types:Dictionary = {
	"bool": load("res://Scenes/Options/BoolOption.tscn").instance(),
	"menu": load("res://Scenes/Options/MenuOption.tscn").instance(),
	"string": load("res://Scenes/Options/StringOption.tscn").instance(),
}

#### OPTIONS MENU CODE!!!! ####

var move_shit:bool = false

var selecting_a_menu:bool = false

var cur_selected:int = 0
var selected_option:int = 0

func _ready():
	MobileControls.switch_to("dpad_with_tab")
	
	if not AudioHandler.get_node("Music/optionsMenu").playing:
		AudioHandler.stop_music()
	
	AudioHandler.play_music("optionsMenu")
	
	spawn_menu_options()
	spawn_options()
	
	yield(get_tree().create_timer(2.5), "timeout")
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(tabnotif, "rect_position", tabnotif.rect_position, Vector2(tabnotif.rect_position.x, tabnotif.rect_position.y - 150), 0.5)
	tween.start()
	
func _physics_process(delta):
	visible_menus.position.x = lerp(visible_menus.position.x, -1600 * cur_selected, delta * 15)
	
	description.rect_size.y = 0
	description.text = options[menus[cur_selected]][selected_option].description
	
	desc_box.rect_size.y = description.rect_size.y + 22
	desc_box.rect_position.y = 585 - (desc_box.rect_size.y - 46)
	
	if move_shit:
		var index = 0
		for option in visible_options.get_children():
			var x = option.global_position.x
			var y = option.global_position.y
			option.global_position.x = lerp(x, 155 + ((index - selected_option) * 17), delta * 10)
			option.global_position.y = lerp(y, 360 + ((index - selected_option) * 155), delta * 10)
			
			index += 1
			
var hold_timer:float = 0.0
	
func _process(delta):
	# just pressed
	if Input.is_action_just_pressed("ui_back"):
		if not keybind_menu.visible and not Transition.transitioning:
			AudioHandler.stop_music()
			AudioHandler.play_music("freakyMenu")
			SceneHandler.switch_to("MainMenu")
			
	if selecting_a_menu:
		if Input.is_action_just_pressed("ui_left"):
			change_selection(-1)
			
		if Input.is_action_just_pressed("ui_right"):
			change_selection(1)
	else:
		if not keybind_menu.visible:
			if Input.is_action_just_pressed("ui_up"):
				change_option(-1)
				
			if Input.is_action_just_pressed("ui_down"):
				change_option(1)
			
			if Input.is_action_just_pressed("ui_accept"):
				var option = visible_options.get_child(selected_option)
				match option.type:
					"bool":
						Options.set_data(option.option, not Options.get_data(option.option))
						option.checked = Options.get_data(option.option)
						option.refresh()
						
						match option.option:
							"memory-leaks":
								if Options.get_data(option.option):
									CoolUtil.leak_memory()
								else:
									CoolUtil.unleak_memory()
							"vsync":
								OS.vsync_enabled = Options.get_data("vsync")
								
					"menu":
						match option.title.text:
							"1k Keybind":
								keybind_menu.keycount = 1
								keybind_menu.visible = true
								keybind_menu.show()
							_:
								if option.title.text.ends_with("k Keybinds"):
									keybind_menu.keycount = int(option.title.text.split("k Keybinds")[0])
									keybind_menu.visible = true
									keybind_menu.show()
									
								if not Transition.transitioning:
									print("SWITCHING MENUS...")
									SceneHandler.switch_to(option.menu_to_load, option.menu_category)
			
	if not keybind_menu.visible and Input.is_action_just_pressed("ui_focus_next"):
		selecting_a_menu = not selecting_a_menu
		
		change_option()
		refresh_shit()
		
	# pressed
	if selecting_a_menu:
		if Input.is_action_pressed("ui_left"):
			left_arrow.rect_scale = Vector2(0.65, 0.65)
			left_arrow.modulate.a = 0.6
		else:
			left_arrow.rect_scale = Vector2(0.8, 0.8)
			
		if Input.is_action_pressed("ui_right"):
			right_arrow.rect_scale = Vector2(0.65, 0.65)
			right_arrow.modulate.a = 0.6
		else:
			right_arrow.rect_scale = Vector2(0.8, 0.8)
	else:
		var left = Input.is_action_pressed("ui_left")
		var right = Input.is_action_pressed("ui_right")
		
		var leftP = Input.is_action_just_pressed("ui_left")
		var rightP = Input.is_action_just_pressed("ui_right")
		
		var option = visible_options.get_child(selected_option)
		
		match option.type:
			"float", "int":
				if left or right:
					hold_timer += delta
					
					if hold_timer > 0.5 or leftP or rightP:
						var mult = option.multiplier
						if left:
							mult = 0 - option.multiplier
							
						if option.type == "int":
							mult = floor(mult)
							
						var final:float = Options.get_data(option.option) + mult
							
						if final < option.limits[0]:
							final = option.limits[0]
							
						if final > option.limits[1]:
							final = option.limits[1]
							
						# ok i can fix the -0 issue using this
						final = abs(final)
							
						Options.set_data(option.option, final)
				else:
					hold_timer = 0
			"string":
				if leftP:
					var a = option.values.find(Options.get_data(option.option))
					a -= 1
					if a < 0:
						a = option.values.size() - 1
						
					Options.set_data(option.option, option.values[a])
					
				if rightP:
					var a = option.values.find(Options.get_data(option.option))
					a += 1
					if a > option.values.size() - 1:
						a = 0
						
					Options.set_data(option.option, option.values[a])
	
func change_selection(amount:int = 0):
	cur_selected += amount
	if cur_selected < 0:
		cur_selected = visible_menus.get_child_count() - 1
	if cur_selected > visible_menus.get_child_count() - 1:
		cur_selected = 0
		
	spawn_options()
		
	AudioHandler.play_audio("scrollMenu")
	
func change_option(amount:int = 0):
	selected_option += amount
	if selected_option < 0:
		selected_option = visible_options.get_child_count() - 1
	if selected_option > visible_options.get_child_count() - 1:
		selected_option = 0
		
	var index = 0
	for option in visible_options.get_children():
		if selected_option == index:
			option.modulate.a = 1
		else:
			option.modulate.a = 0.6
		
		index += 1
		
	AudioHandler.play_audio("scrollMenu")
	
func spawn_menu_options():
	for i in menus.size():
		var new_menu = menu_template.duplicate()
		new_menu.visible = true
		new_menu.text = menus[i]
		new_menu.rect_position.x = 1600 * i
		visible_menus.add_child(new_menu)
		
func spawn_options():
	move_shit = false
	for i in visible_options.get_children():
		i.queue_free()
		
	var index:int = 0
	for option in options[menus[cur_selected]]:
		var new_option = null
		match option.type:
			"menu":
				new_option = option_types["menu"].duplicate()
				new_option.type = "menu"
				
				new_option.global_position.x = 72 + (index * 17)
				new_option.global_position.y = 100 + (index * 70)
				visible_options.add_child(new_option)
				
				new_option.option_title = option.title
				new_option.title.text = option.title
				new_option.description = option.description
				
				if "menu_to_load" in option:
					new_option.menu_to_load = option.menu_to_load
					new_option.menu_category = option.menu_category
				
			"float", "int":
				new_option = option_types["string"].duplicate()
				new_option.type = option.type
				
				new_option.global_position.x = 72 + (index * 17)
				new_option.global_position.y = 100 + (index * 70)
				visible_options.add_child(new_option)
				
				new_option.option_title = option.title
				new_option.title.text = option.title
				new_option.description = option.description
				
				new_option.option = option.save_data_name
				
				new_option.multiplier = option.multiplier
				new_option.limits = option.limits
				
				new_option.decimals_lol = option.decimals
				
			"string":
				new_option = option_types["string"].duplicate()
				new_option.type = "string"
				
				new_option.global_position.x = 72 + (index * 17)
				new_option.global_position.y = 100 + (index * 70)
				visible_options.add_child(new_option)
				
				new_option.option_title = option.title
				new_option.title.text = option.title
				new_option.description = option.description
				
				new_option.option = option.save_data_name
				
				new_option.values = option.values
				
			_:
				new_option = option_types["bool"].duplicate()
				new_option.type = "bool"
				
				new_option.global_position.x = 72 + (index * 17)
				new_option.global_position.y = 100 + (index * 70)
				visible_options.add_child(new_option)
				
				new_option.option_title = option.title
				new_option.title.text = option.title
				new_option.description = option.description
				
				new_option.option = option.save_data_name
				new_option.checked = Options.get_data(option.save_data_name)
				new_option.refresh()
				
		index += 1
		
	move_shit = true
	selected_option = 0
	change_option()
	
	refresh_shit()
	
func refresh_shit():
	if selecting_a_menu:
		visible_options.modulate.a = 0.4
		bar.modulate.a = 1
		left_arrow.modulate.a = 1
		right_arrow.modulate.a = 1
	else:
		visible_options.modulate.a = 1
		bar.modulate.a = 0.4
		left_arrow.modulate.a = 0.4
		right_arrow.modulate.a = 0.4
