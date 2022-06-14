extends CanvasLayer

onready var anim:AnimationPlayer = $anim
onready var gradient:TextureRect = $gradient

func transIn():
	anim.play("in")
	
func transOut():
	anim.play("out")
