extends Node2D

onready var spr:AnimatedSprite = $AnimatedSprite
onready var anim:AnimationPlayer = $AnimationPlayer

func switchTo(animToPlay:String):
	if anim.has_animation(animToPlay):
		anim.play(animToPlay)
	else:
		anim.play("normal")

func _on_AnimationPlayer_animation_finished(anim_name):
	anim.seek(0.0)
	anim.play(anim_name)
