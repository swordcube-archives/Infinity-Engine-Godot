extends Node2D

var direction:String = "A"

onready var spr = $spr

func _ready():
	spr.frames = PlayStateSettings.currentUiSkin.note_splash_tex
	var s = PlayStateSettings.currentUiSkin.note_splash_scale
	scale = Vector2(s, s)
	modulate.a = 0.6
	spr.play(direction)

func _on_spr_animation_finished():
	queue_free()
