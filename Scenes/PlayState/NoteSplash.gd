extends Node2D

onready var spr = $spr
var direction:String = "A"

func _ready():
	randomize()

var colors:Dictionary = {
	"A": [
		"note impact 1 purple",
		"note impact 2 purple"
	],
	"B": [
		"note impact 1 blue",
		"note impact 2 blue"
	],
	"C": [
		"note impact 1 green",
		"note impact 2 green"
	],
	"D": [
		"note impact 1 red",
		"note impact 2 red"
	],
	"E": [
		"note impact 1 gray",
		"note impact 2 gray"
	],
	"F": [
		"note impact 1 yellow",
		"note impact 2 yellow"
	],
	"G": [
		"note impact 1 purple2",
		"note impact 2 purple2"
	],
	"H": [
		"note impact 1 red2",
		"note impact 2 red2"
	],
	"I": [
		"note impact 1 blue2",
		"note impact 2 blue2"
	],
}

func splash():
	spr.frames = GameplaySettings.ui_skin.note_splash_tex
	visible = true
	spr.modulate.a = 0.6
	spr.play(colors[direction][randi()%2])
	spr.speed_scale = rand_range(0.7, 1)

func _on_spr_animation_finished():
	queue_free()
