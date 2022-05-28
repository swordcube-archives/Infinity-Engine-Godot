extends Node2D

class_name Event

export(String, MULTILINE) var description:String = ""
export(Array) var parameters:Array = ["???"]

# this has the values for the parameters
# you'll type the values inside of the charter
var params:Dictionary = {}

func on_event():
	pass
