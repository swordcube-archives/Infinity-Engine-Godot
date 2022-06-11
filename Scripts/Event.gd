extends Node2D

class_name Event

export(String, MULTILINE) var description:String = ""
export(Array) var parameters:Array = ["???"]

var PlayState = null

# this has the values for the parameters
# you'll type the values inside of the charter
var params:Dictionary = {}

func on_event():
	pass
	
func get_character_from_argument(argument:String):
	match argument.to_lower():
		"0", "player2", "dad":
			return PlayState.dad
		"1", "player3", "gf":
			return PlayState.gf
		_:
			return PlayState.bf
