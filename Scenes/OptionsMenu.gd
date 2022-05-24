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

var pages:Dictionary = {}

#### OPTIONS MENU CODE!!!! ####

var move_shit:bool = false

var selecting_a_menu:bool = false

var cur_selected:int = 0
var selected_option:int = 0

func _ready():
	# makes it so you just add nodes to make pages
	# the options menu system makes more sense now i think
	for page in $Pages.get_children():
		pages[page.name] = page
		
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
	
	if move_shit:
		description.rect_size.y = 0
		var desc:String = visible_options.get_child(selected_option).description
		description.text = desc.replace('\\n', "\n")
		
		desc_box.rect_size.y = description.rect_size.y + 22
		desc_box.rect_position.y = 585 - (desc_box.rect_size.y - 46)
		
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
							
						# ok nvm we go back to this
						# i just realized, i think this would make
						# negative shit impossible to do with abs
						if final == -0:
							final = 0
							
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
	for i in pages.keys().size():
		var new_menu = menu_template.duplicate()
		new_menu.visible = true
		new_menu.text = pages.keys()[i]
		new_menu.rect_position.x = 1600 * i
		visible_menus.add_child(new_menu)
		
func spawn_options():
	move_shit = false
	for i in visible_options.get_children():
		visible_options.remove_child(i)
		i.queue_free()
		
	var index:int = 0
	for option in pages[pages.keys()[cur_selected]].get_children():
		var new_option = option.duplicate()
		new_option.visible = true
		new_option.global_position.x = 72 + (index * 17)
		new_option.global_position.y = 100 + (index * 70)
		visible_options.add_child(new_option)
		
		match new_option.type:
			"bool":
				new_option.checked = Options.get_data(new_option.option)
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
