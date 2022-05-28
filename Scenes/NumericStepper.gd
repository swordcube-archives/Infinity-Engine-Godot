tool
extends Node2D

export(float) var minimum:float = 0
export(float) var maximum:float = 1
export(float) var multiplier:float = 0.5

export(float) var value:float = 0

func _process(delta):
	$LineEdit.text = str(value)

func _on_Plus_pressed():
	value += multiplier
	if value > maximum:
		value = maximum
		
func _on_Minus_pressed():
	value -= multiplier
	if value < minimum:
		value = minimum
