extends Node2D

var offset:float = 0

var is_bool = false

var waiting_for_input = false

onready var text = $Text
onready var parent = $"../"

export(String) var description = "The Custom Scroll Speed to use."

func _ready():
	var offset = Settings.get_data("custom_scroll")
	text.text = "SCROLL: " + str(offset)

func _process(_delta):
	if waiting_for_input:
		var offset = Settings.get_data("custom_scroll")
		
		if Input.is_action_just_pressed("ui_back"):
			open_option()
		if Input.is_action_just_pressed("ui_left") and !Input.is_action_pressed("ui_shift"):
			offset -= 0.1
		if Input.is_action_just_pressed("ui_right") and !Input.is_action_pressed("ui_shift"):
			offset += 0.1
		
		if Input.is_action_just_pressed("ui_left") and Input.is_action_pressed("ui_shift"):
			offset -= 1
		if Input.is_action_just_pressed("ui_right") and Input.is_action_pressed("ui_shift"):
			offset += 1
			
		if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
			Settings.set_data("custom_scroll", offset)
			text.text = "SCROLL: " + str(offset)
		

func open_option():
	waiting_for_input = !waiting_for_input
	
	parent.can_move = !waiting_for_input
