tool
extends Node2D

var oldEnabled:bool = false
export(bool) var enabled:bool = true

func _process(delta):
	if oldEnabled != enabled:
		oldEnabled = enabled
		refresh()
		
func refresh():
	var anim:String = str(enabled).to_lower()
	$AnimatedSprite.play(anim)
	$AnimationPlayer.play(anim)
