extends Node2D

var mod = ""

func _ready():
	$Checkbox/Text.modulate = Color("FFFFFF")
	
func _process(delta):
	if $Checkbox.checked:
		$Checkbox/Text.text = "[ON]"
	else:
		$Checkbox/Text.text = "[OFF]"
