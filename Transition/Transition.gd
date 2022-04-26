extends CanvasLayer

var transitioning = false
export(float) var duration = 0.55

func _physics_process(delta):
	if $anim.is_playing():
		transitioning = true
	else:
		transitioning = false

func _fade_in():
	$anim.play("in")

func _fade_out():
	$anim.play("out")
