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
						"Makes your notes scroll downwards instead of upwards.", # desc
						"bool", # type
					],
					[
						"Middlescroll", # title
						"Makes your notes centered on-screen.", # desc
						"bool", # type
					],
					[
						"Note Offset", # title
						"Change how late or early your notes spawn.\nNegative = Earlier - Positive = Later", # desc
						"float", # type
						0.5, # multiplier
						[-1000, 1000], # min and max
						1, # decimals to display
					]
				]
				$Misc/Transition.transition_to_scene("Options/BaseOptionsMenu")
			"Controls":
				$Misc/Transition.transition_to_scene("Options/BaseOptionsMenu")
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
