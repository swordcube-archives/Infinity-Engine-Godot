extends Node2D

var canEnter = true

func _process(delta):
	if canEnter:
		if Input.is_action_just_pressed("ui_accept"):
			canEnter = false
			
			$PressEnter.play("pressed")
			$"/root/AudioHandler".play_audio("confirmMenu")
			
			$Flash.visible = true
			var tween = Tween.new()
			tween.interpolate_property($Flash, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 2)
			add_child(tween)
			tween.start()
			
			var timer = Timer.new()
			timer.set_wait_time(2)
			add_child(timer)
			timer.start()
			timer.set_one_shot(true)
			
			yield(timer, "timeout")
			SceneManager.transition_to_scene("MainMenu")
