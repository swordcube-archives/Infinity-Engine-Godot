extends Node2D

class_name FreeplaySong

onready var icon = $Icon

onready var label = $Label

var xAdd:float = 0
var yAdd:float = 0

var isMenuItem:bool = false
var targetY:float = 0

func _process(delta):
	if isMenuItem:
		var lerpVal:float = delta * 9.6
		position.x = lerp(position.x, (targetY * 20) + 90 + xAdd, lerpVal)
		position.y = lerp(position.y, (targetY * 120) + (720 * 0.4) + yAdd, lerpVal)
