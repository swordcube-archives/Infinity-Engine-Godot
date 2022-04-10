extends Node2D

var curSelected = 0
var canSelect = true

var button_visible = true
var can_flash = true

var progress = false

var timer = Timer.new()
var timer2 = Timer.new()

func _ready():
	if not AudioHandler.get_node("Inst").playing and not AudioHandler.get_node("Voices").playing and not AudioHandler.get_node("freakyMenu").playing:
		AudioHandler.play_audio("freakyMenu")
		
	change_selection(0)
	
	$Misc/Transition._fade_out()

func _process(delta):
	$Misc/Version.text = "v" + EngineSettings.game_version + " - " + EngineSettings.version_status
	
	if Input.is_action_just_pressed("ui_back"):
		$Misc/Transition.transition_to_scene("TitleScreen")
		AudioHandler.play_audio("cancelMenu")
		
	if canSelect:
		if Input.is_action_just_pressed("ui_up"):
			change_selection(-1)
			
		if Input.is_action_just_pressed("ui_down"):
			change_selection(1)
			
		if Input.is_action_just_pressed("ui_accept"):
			select_menu()
			
	if not progress:
		$Buttons/ButtonsParallax.get_children()[curSelected].visible = button_visible
	else:
		$Buttons/ButtonsParallax.get_children()[curSelected].visible = false
		$BGShit/BGParallax/BGMagenta.visible = false
		
func select_menu():
	AudioHandler.play_audio("confirmMenu")
	
	canSelect = false
	
	# fade out the buttons that aren't selected
	var tween = Tween.new()
	
	for i in $Buttons/ButtonsParallax.get_child_count():
		if not curSelected == i:
			tween.interpolate_property($Buttons/ButtonsParallax.get_children()[i], "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.65)
		
	add_child(tween)
	tween.start()
	
	var flash_timer = Timer.new()
	flash_timer.set_wait_time(1)
	add_child(flash_timer)
	flash_timer.start()
	flash_timer.set_one_shot(true)
	
	flash_timer.connect("timeout", self, "stop_flashing")
	
	timer.set_wait_time(0.05)
	add_child(timer)
	timer.start()
	
	timer2.set_wait_time(0.15)
	add_child(timer2)
	timer2.start()
	
	doFlash1()
	doFlash2()
	
func doFlash1():
	while can_flash:
		yield(timer, "timeout")
		button_visible = not button_visible
		
func doFlash2():
	while can_flash:
		yield(timer2, "timeout")
		$BGShit/BGParallax/BGMagenta.visible = not button_visible
		
func stop_flashing():
	can_flash = false
	button_visible = false
	progress = true
	
	match($Buttons/ButtonsParallax.get_children()[curSelected].name):
		"StoryMode":
			$Misc/Transition.transition_to_scene("StoryMenu")
		"Freeplay":
			$Misc/Transition.transition_to_scene("FreeplayMenu")
		"Mods":
			$Misc/Transition.transition_to_scene("ModsMenu")
		"Options":
			$Misc/Transition.transition_to_scene("Options/OptionsMenu")
			
		
func change_selection(amount):
	AudioHandler.play_audio("scrollMenu")
	$Buttons/ButtonsParallax.get_children()[curSelected].play("basic")
	
	curSelected += amount
	
	if curSelected < 0:
		curSelected = $Buttons/ButtonsParallax.get_child_count() - 1
		
	if curSelected > $Buttons/ButtonsParallax.get_child_count() - 1:
		curSelected = 0
		
	$Cam.position.y = $Buttons/ButtonsParallax.get_children()[curSelected].position.y
		
	$Buttons/ButtonsParallax.get_children()[curSelected].play("white")
