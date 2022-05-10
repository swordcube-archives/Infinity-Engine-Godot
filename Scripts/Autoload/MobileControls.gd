extends Node2D

onready var controls = [
	$DPad/CanvasModulate,
	$MenuDPad/CanvasModulate,
	$Hitbox/CanvasModulate,
	$Title/CanvasModulate,
	$DPadWithTab/CanvasModulate,
	$DPadWithShift/CanvasModulate,
	$DPadPauseMenu/CanvasModulate
]

func _ready():
	switch_to("dpad")

func switch_to(type:String = "none"):
	for control in controls:
		control.visible = false
		
	match type.to_lower():
		"dpad":
			controls[0].visible = true
		"menudpad":
			controls[1].visible = true
		"hitbox":
			controls[2].visible = true
		"title":
			controls[3].visible = true
		"dpad_with_tab":
			controls[4].visible = true
		"dpad_with_shift":
			controls[5].visible = true
		"dpad_pausemenu":
			controls[6].visible = true
		_:
			print("CONTROL " + type + " NOT FOUND!")
