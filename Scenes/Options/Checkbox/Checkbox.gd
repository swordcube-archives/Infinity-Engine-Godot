extends Node2D

var checked = false

var old_checked = true

func _process(delta):
	if not old_checked == checked:
		old_checked = checked
		
		if checked:
			$Box.anim.play("checked")
		else:
			$Box.anim.play("unchecked")
