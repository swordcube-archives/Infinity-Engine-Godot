extends Node

func switch_scene(scene, transition = true):
	if transition:
		if not Transition.transitioning:
			Transition._fade_in()
			
			var timer = Timer.new()
			timer.set_wait_time(Transition.duration)
			add_child(timer)
			timer.start()
			timer.set_one_shot(true)
			
			yield(timer, "timeout")
			get_tree().change_scene("res://Scenes/" + scene + ".tscn")
			timer.stop()
			timer = null
			Transition._fade_out()
	else:
		get_tree().change_scene("res://Scenes/" + scene + ".tscn")
