extends Node2D

var anim_finished = false

export(String) var direction = "A"

func _ready():
	play_anim("static")

func play_anim(anim, backwards = false):
	anim_finished = false
	$key.frame = 0
	match anim:
		"press":
			$key.play(direction + " press", backwards)
		"confirm":
			$key.play(direction + " confirm", backwards)
		"static":
			$key.play(direction + " static", backwards)
		_:
			$key.play(direction + anim, backwards)

func _on_key_animation_finished():
	anim_finished = true
