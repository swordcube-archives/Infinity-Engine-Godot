extends Node

export(String) var alignment = "left"
export(Array) var emotions = ["confused", "excited", "normal", "pissed", "shocked"]

export(String) var current_emotion = "normal"

func talk():
	can_idle = false

var idle_timer = 0
var can_idle = true

func _physics_process(delta):
	if can_idle:
		idle_timer += delta
		
		if idle_timer > 0.5:
			idle_timer = 0
			$anim.play(current_emotion + " idle")
	else:
		can_idle = true
		$anim.play(current_emotion + " talk")

func _on_anim_animation_finished(anim_name):
	can_idle = true
