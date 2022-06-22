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
		var scaledY = MathUtil.remapToRange(targetY, 0, 1, 0, 1.3);
		var lerpVal:float = MathUtil.boundTo(delta * 9.6, 0, 1)
		position.x = lerp(position.x, (targetY * 20) + 90 + xAdd, lerpVal)
		position.y = lerp(position.y, (scaledY * 120) + (720 * 0.46) + yAdd, lerpVal)
