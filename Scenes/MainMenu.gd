extends Node2D

var cur_selected:int = 0
var flashing:bool = false

onready var cam = $Camera2D
onready var bg = $ParallaxBackground/BGLayer/BG
onready var bg2 = $ParallaxBackground/BGLayer/BG2
onready var buttons = $ParallaxBackground/Buttons.get_children()

onready var label = $UI/Label

func _ready():
	MobileControls.switch_to("menudpad")
	
	AudioHandler.play_music("freakyMenu")
	
	change_selection()
	
	label.text = "v" + CoolUtil.engine_version

func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		change_selection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		change_selection(1)
		
	if Input.is_action_just_pressed("ui_back"):
		if not Transition.transitioning:
			AudioHandler.play_audio("cancelMenu")
			SceneHandler.switch_to("TitleScreen")
		
	if Input.is_action_just_pressed("ui_accept"):
		if not flashing:
			flashing = true
			AudioHandler.play_audio("confirmMenu")
			select_thing()
			
	if flashing:
		do_flashing(delta)
		
var flash_timer:float = 0.0
var flash_bg_timer:float = 0.0

var stop_timer:float = 0.0

var bruj:bool = false
		
func do_flashing(delta):
	flash_timer += delta
	flash_bg_timer += delta
	
	stop_timer += delta
	
	if stop_timer < 1.2:
		if flash_bg_timer > 0.15:
			flash_bg_timer = 0
			bg2.visible = !bg2.visible
			
		if flash_timer > 0.05:
			flash_timer = 0
			var b = buttons[cur_selected]
			b.visible = !b.visible
	else:
		if not bruj:
			bruj = true
			var b = buttons[cur_selected]
			b.visible = false
			
			bg2.visible = false
		
func change_selection(amount:int = 0):
	cur_selected += amount
	
	if cur_selected < 0:
		cur_selected = buttons.size() - 1
		
	if cur_selected > buttons.size() - 1:
		cur_selected = 0
		
	for i in buttons.size():
		if cur_selected == i:
			buttons[i].play("white")
		else:
			buttons[i].play("basic")
			
	cam.position.y = buttons[cur_selected].position.y - 69 # funni number
	AudioHandler.play_audio("scrollMenu")
	
func select_thing():
	var tween = $Tween
	for i in buttons.size():
		if not cur_selected == i:
			var b = buttons[i]
			tween.interpolate_property(b, "modulate", b.modulate, Color(1, 1, 1, 0), 0.5)

	tween.start()
	
	yield(get_tree().create_timer(1.3), "timeout")
	var b = buttons[cur_selected]
	match b.name:
		"StoryMode":
			SceneHandler.switch_to("StoryMenu")
		"Freeplay":
			SceneHandler.switch_to("FreeplayMenu")
		"Mods":
			SceneHandler.switch_to("ModsMenu")
		"Credits":
			SceneHandler.switch_to("CreditsMenu")
		"Options":
			SceneHandler.switch_to("OptionsMenu")
