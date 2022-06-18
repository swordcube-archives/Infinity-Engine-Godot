extends Node2D

onready var anim:AnimationPlayer = $AnimationPlayer

var danced:bool = false

func dance():
	danced = not danced
	if danced:
		anim.play("danceLeft")
	else:
		anim.play("danceRight")
