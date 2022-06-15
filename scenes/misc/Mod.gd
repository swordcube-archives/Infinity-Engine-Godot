extends Node

export(String) var title:String = "Infinity Engine"
export(String, MULTILINE) var description:String = "The base engine, DO NOT DISABLE."

export(String, MULTILINE) var icon:String = "Change res://assets/images/modIcon.png. Changing this does literally nothing."

# don't change this
var realIcon:StreamTexture = preload("res://assets/images/modIcon.png")
