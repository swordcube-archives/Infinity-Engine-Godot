extends Node2D

var noteData:int = 0

var colors = [
	["gray"],
	["purple", "red"],
	["purple", "gray", "red"],
	["purple", "blue", "green", "red"],
	["purple", "blue", "gray", "green", "red"],
	["purple", "blue", "red", "yellow", "green", "blue2"],
	["purple", "blue", "red", "gray", "yellow", "green", "blue2"],
	["purple", "blue", "green", "red", "yellow", "purple2", "red2", "blue2"],
	["purple", "blue", "green", "red", "gray", "yellow", "purple2", "red2", "blue2"],
]

func _ready():
	# i will make the actual note splashes tmr, usign old shit from
	# old infinity engine as a placeholder rn
	
	#$spr.play("note impact " + str(int(rand_range(1, 2))) + " " + colors[Gameplay.key_count - 1][noteData % Gameplay.key_count])
	$spr.play(colors[Gameplay.key_count - 1][noteData % Gameplay.key_count])
	$spr.modulate.a = 0.6
	
	randomize()
	$spr.speed_scale = rand_range(0.5, 1)

func _on_spr_animation_finished():
	queue_free()
