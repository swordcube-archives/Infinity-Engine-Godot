extends Node2D

var flashValues:Array = [1, 0]

var flashing:bool = false
export(float) var flashTimer:float = 0.0

export(float) var flashSpeed:float = 0.06

func _process(delta):
	if flashing:
		flashTimer += delta
		if flashTimer > flashSpeed:
			flashTimer = 0
			flashValues.invert()
			modulate.a = flashValues[0]
	else:
		flashTimer = 0
