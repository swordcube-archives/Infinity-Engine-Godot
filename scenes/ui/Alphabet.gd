tool
extends Node2D

onready var label = $Label

var oldText:String = ""
export(String) var text:String = ""

func _ready():
	$AnimationPlayer.play("default")

func _process(delta):
	if oldText != text:
		updateText()
		
func updateText():
	$Label.text = text
	$Label.rect_size.x = 0
