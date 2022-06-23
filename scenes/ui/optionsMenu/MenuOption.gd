extends Node2D

class_name MenuOption

export(String) var saveDataOption:String = ""
export(String, MULTILINE) var optionDescription:String = ""

# THIS IS FOR OPTIONS LIKE "Scroll Speed" THAT NEED "Custom Scroll Speed"
# OR SMTH ENABLED TO WORK!
export(String) var optionNeeded:String = ""

# this is an array so you just add one item that can be any type
export(Array) var neededValue:Array = []

var xAdd:float = 0
var yAdd:float = 0

var isMenuItem:bool = false
var targetY:float = 0

var isTool:bool = true

func _process(delta):
	if isMenuItem:
		var scaledY = MathUtil.remapToRange(targetY, 0, 1, 0, 1.3);
		var lerpVal:float = MathUtil.boundTo(delta * 9.6, 0, 1)
		position.x = lerp(position.x, (targetY * 20) + 90 + xAdd, lerpVal)
		position.y = lerp(position.y, (scaledY * 120) + (720 * 0.46) + yAdd, lerpVal)
