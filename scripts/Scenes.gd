extends Node

var transitioning:bool = false

func switchScene(scene:String, transition:bool = true):
	if transition:
		transitioning = true
		get_tree().paused = true
		Transition.transIn()
		var inTimer:SceneTreeTimer = get_tree().create_timer(Transition.anim.get_animation("in").length + 0.05)
		yield(inTimer, "timeout")
		get_tree().change_scene("res://scenes/" + scene + ".tscn")
		Transition.transOut()
		var outTimer:SceneTreeTimer = get_tree().create_timer(Transition.anim.get_animation("out").length + 0.05)
		yield(outTimer, "timeout")
		transitioning = false
		get_tree().paused = false
