extends Node2D

export(String) var direction = "A"

var anim_finished:bool = false
onready var label = $Label

func _ready():
	play_anim("static")

func play_anim(anim):
	anim_finished = false
	$spr.stop()
	$spr.frame = 0
	match anim:
		"press", "pressed":
			$spr.play(direction + " press")
		"confirm":
			$spr.play(direction + " confirm")
		_:
			$spr.play(direction + " static")

func _on_spr_animation_finished():
	anim_finished = true
