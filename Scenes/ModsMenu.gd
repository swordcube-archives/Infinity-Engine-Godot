extends Node2D

var curSelected = 0

var unactive_desc = "Turn on this mod to see it's info!"

func _ready():
	ModManager.init_mods()
	
	if not AudioHandler.get_node("Inst").playing and not AudioHandler.get_node("Voices").playing and not AudioHandler.get_node("freakyMenu").playing:
		AudioHandler.play_audio("freakyMenu")
		
	$Misc/Transition._fade_out()
	
	list_mods()
	change_selection(0)
	
	var index = 0
	for mod in ModManager.mods:
		var piss = $Mods.get_children()[index]
		piss.get_node("Checkbox").checked = ModManager.get_active(mod)
		
		if ModManager.get_active(mod):
			piss.get_node("Description").text = ModManager.mod_instances[mod].description
		else:
			piss.get_node("Description").text = unactive_desc
		
		index += 1
	
func change_selection(amount):
	AudioHandler.play_audio("scrollMenu")
	
	curSelected += amount
	if curSelected < 0:
		curSelected = $Mods.get_child_count() - 1
	if curSelected > $Mods.get_child_count() - 1:
		curSelected = 0
	
func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		change_selection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		change_selection(1)
		
	if Input.is_action_just_pressed("ui_accept"):
		var mod = ModManager.mods[curSelected]
		var piss = $Mods.get_children()[curSelected]
		
		ModManager.set_active(mod, not ModManager.get_active(mod))
		ModManager.init_mods()
		piss.get_node("Checkbox").checked = ModManager.get_active(mod)
		
		if ModManager.get_active(mod):
			piss.get_node("Description").text = ModManager.mod_instances[mod].description
		else:
			piss.get_node("Description").text = unactive_desc
		
	if Input.is_action_just_pressed("ui_back"):
		$Misc/Transition.transition_to_scene("MainMenu")
		
	var index = 0
	for mod in $Mods.get_children():
		if curSelected == index:
			mod.modulate.a = lerp(mod.modulate.a, 1, delta * 15)
			mod.scale = lerp(mod.scale, Vector2(1, 1), delta * 15)
		else:
			mod.modulate.a = lerp(mod.modulate.a, 0.6, delta * 15)
			mod.scale = lerp(mod.scale, Vector2(0.85, 0.85), delta * 15)
			
		mod.global_position.y = lerp(mod.global_position.y, 360 + (190 * index) - (190 * curSelected), delta * 15)
			
		index += 1
			
func list_mods():
	var index = 0
	for mod in ModManager.mods:
		var newMod = $Template.duplicate()
		newMod.visible = true
		newMod.global_position = Vector2(640, 360 + (190 * index))
		newMod.mod = mod
		newMod.get_node("Title").text = mod
		newMod.get_node("Description").text = unactive_desc
		newMod.get_node("Author").text = "By: ???"
		newMod.get_node("Icon").texture = Paths.image("unknown_mod")
		$Mods.add_child(newMod)
		
		index += 1
