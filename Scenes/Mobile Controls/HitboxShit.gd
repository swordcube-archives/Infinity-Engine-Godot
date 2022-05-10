extends CanvasModulate

# ik this is kinda dumb but like, i don't care

onready var buttons = [
	$"0",
	$"1",
	$"2",
	$"3",
]

func _on_0_pressed():
	buttons[0].modulate.a = 0.4

func _on_1_pressed():
	buttons[1].modulate.a = 0.4

func _on_2_pressed():
	buttons[2].modulate.a = 0.4

func _on_3_pressed():
	buttons[3].modulate.a = 0.4
