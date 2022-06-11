extends Node2D

onready var spr = $spr
var direction:String = "A"

func _ready():
	randomize()

var colors:Dictionary = {
	"A": [
		"A"
	],
	"B": [
		"B"
	],
	"C": [
		"C"
	],
	"D": [
		"D"
	],
	"E": [
		"E"
	],
	"F": [
		"F"
	],
	"G": [
		"G"
	],
	"H": [
		"H"
	],
	"I": [
		"I"
	],
}

func splash():
	spr.frames = GameplaySettings.ui_skin.note_splash_tex
	visible = true
	spr.modulate.a = 0.6
	spr.play(colors[direction][randi()%(colors[direction].size())])
	spr.speed_scale = rand_range(0.7, 1)

func _on_spr_animation_finished():
	queue_free()
