tool
extends Node2D

signal changed_value(value)

var old_text:String = ""

var old_default:float = 0.0

export(float) var value:float = 0.0
export(float) var min_value:float = 0.0
export(float) var max_value:float = 100.0
export(float) var step_amount:float = 1.0

func _process(delta):
	if old_default != value:
		old_default = value
		$LineEdit.text = str(value)
		emit_signal("changed_value", value)
		
	if old_text != $LineEdit.text:
		old_text = $LineEdit.text
		value = float($LineEdit.text)
		old_default = value
		emit_signal("changed_value", value)

func _on_Plus_pressed():
	var num:float = clamp(stepify(float($LineEdit.text)+step_amount, step_amount), min_value, max_value)
	$LineEdit.text = str(num)
	value = num

func _on_Minus_pressed():
	var num:float = clamp(stepify(float($LineEdit.text)-step_amount, step_amount), min_value, max_value)
	$LineEdit.text = str(num)
	value = num
