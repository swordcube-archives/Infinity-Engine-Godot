extends Node

func switch_to(scene:String, type:String = "", transition:bool = true):
	if not Transition.transitioning:
		var path = scene
		
		if len(type) > 0:
			path = type + "/" + scene
			
		if ResourceLoader.exists("res://Scenes/" + path + ".tscn"):
			if transition:
				Transition.fade_in()
				yield(get_tree().create_timer(Transition.anim.get_animation("in").length), "timeout")
				get_tree().change_scene("res://Scenes/" + path + ".tscn")
			else:
				get_tree().change_scene("res://Scenes/" + path + ".tscn")
			
			if transition:
				Transition.fade_out()
				
func switch_to_raw(scene:String, transition:bool = true):
	if not Transition.transitioning:
		var path:String = scene
		
		if ResourceLoader.exists(path):
			if transition:
				Transition.fade_in()
				yield(get_tree().create_timer(Transition.anim.get_animation("in").length), "timeout")
				get_tree().change_scene(path)
			else:
				get_tree().change_scene(path)
			
			if transition:
				Transition.fade_out()
