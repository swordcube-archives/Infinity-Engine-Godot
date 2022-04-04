extends Node2D

var noteData:int = 0

var colors = ["purple", "blue", "green", "red"]

func _ready():
	$spr.play("note impact " + str(int(rand_range(1, 2))) + " " + colors[noteData % 4])
	$spr.modulate.a = 0.6
	
	randomize()
	$spr.speed_scale = rand_range(0.3, 1)

func _on_spr_animation_finished():
	queue_free()
