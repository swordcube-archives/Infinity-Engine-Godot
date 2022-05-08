extends Option

onready var title = $text

var checked:bool = false

func refresh():
	if checked:
		$anim.play("checked")
	else:
		$anim.play("unchecked")
