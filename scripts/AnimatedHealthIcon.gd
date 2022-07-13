extends Node2D

onready var spr:AnimatedSprite = $AnimatedSprite
onready var anim:AnimationPlayer = $AnimationPlayer

var curAnim:String = "normal"

func switchTo(animToPlay:String):
	if anim.has_animation(animToPlay):
		curAnim = animToPlay
	else:
		curAnim = "normal"
		
	anim.play(curAnim)

func _on_AnimationPlayer_animation_finished(anim_name):
	anim.seek(0.0)
	anim.play(curAnim)
