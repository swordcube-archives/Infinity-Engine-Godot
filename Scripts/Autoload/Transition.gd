extends CanvasLayer

onready var spr = $spr
onready var anim = $anim

var transitioning:bool = false

func fade_in():
	transitioning = true
	anim.play("in")
	
func fade_out():
	transitioning = true
	anim.play("out")

func _on_anim_animation_finished(anim_name):
	transitioning = false
