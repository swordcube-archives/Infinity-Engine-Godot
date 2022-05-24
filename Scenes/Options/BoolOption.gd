extends Option

onready var title = $text

var checked:bool = false

func _ready():
	title.text = name

func refresh():
	if checked:
		$anim.play("checked")
	else:
		$anim.play("unchecked")
