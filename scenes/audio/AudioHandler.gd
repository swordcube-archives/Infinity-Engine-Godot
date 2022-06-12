extends Node

func playSFX(a, pos:float = 0.0):
	var node = get_node("SFX/" + a)
	if node != null:
		var clone = node.duplicate()
		clone.isClone = true
		clone.play()
		get_tree().current_scene.add_child(clone)
