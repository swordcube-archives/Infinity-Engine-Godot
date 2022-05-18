extends Node2D

onready var tools = $Tools

var cur_selected:int = 0

var ready:bool = false

func _ready():
	change_selection()
	
	yield(get_tree().create_timer(0.5), "timeout")
	ready = true
	
func _physics_process(delta):
	var index:int = 0
	for item in tools.get_children():
		var x = item.rect_position.x
		var y = item.rect_position.y
		item.rect_position.x = lerp(x, 95 + ((index - cur_selected) * 17), delta * 10)
		item.rect_position.y = lerp(y, 335 + ((index - cur_selected) * 155), delta * 10)

		index += 1

func _process(delta):
	if Input.is_action_just_pressed("ui_back"):
		SceneHandler.switch_to("OptionsMenu")
		
	if Input.is_action_just_pressed("ui_up"):
		change_selection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		change_selection(1)
		
	if Input.is_action_just_pressed("ui_accept"):
		var menu = tools.get_child(cur_selected).menu
		SceneHandler.switch_to_raw(menu)
		
func change_selection(amount:int = 0):
	cur_selected += amount
	if cur_selected < 0:
		cur_selected = tools.get_child_count() - 1
	if cur_selected > tools.get_child_count() - 1:
		cur_selected = 0
		
	var index:int = 0
	for item in tools.get_children():
		if cur_selected == index:
			item.modulate.a = 1
		else:
			item.modulate.a = 0.6
		
		index += 1
		
	AudioHandler.play_audio("scrollMenu")
