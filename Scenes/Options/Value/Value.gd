extends Node2D

var type = "float"
var value = "downscroll"
var title = "Downscroll"

var decimal_shit:int = 1

func _process(delta):
	if type == "float" or type == "int":
		$Text.text = title + "            " + str(Util.round_decimal(float(Options.get_data(value)), decimal_shit))
	else:
		$Text.text = title + "            " + str(Options.get_data(value))
