extends Node2D

func _ready():
	$Misc/Transition._fade_out()

func _process(delta):
	if Input.is_action_just_pressed("ui_back"):
		$Misc/Transition.transition_to_scene("Options/OptionsMenu")
