extends Node

var scene = null

# btw pass = skip this function, I think.
# if you wanna use the function, delete the pass part and go nuts

# DO NOT DELETE THE FUNCTION IF IT'S UNUSED, OTHERWISE
# THE GAME WILL SHIT ITSELF.

var fuck = 0.0

func _ready(): #  this is the create function, runs when the song loads in
	pass
	
func _process(delta): # this is the update function, runs every frame.
	if not scene.countdown_active:
		fuck += delta * 5
		
		var index = 0
		scene.get_node("camHUD/OpponentStrums").global_position.x = lerp(scene.get_node("camHUD/OpponentStrums").global_position.x, -600, delta * 2)
		scene.get_node("camHUD/PlayerStrums").global_position.x = lerp(scene.get_node("camHUD/PlayerStrums").global_position.x, ScreenRes.screen_width / 2.72, delta * 2)
		for strum in scene.get_node("camHUD/PlayerStrums").get_children():
			strum.position.y = sin(fuck + index) * 30
			index += 1
	
func _beat_hit(): # this is a function that runs every beat
	pass
	
func _step_hit(): # this is _beat_hit but it happens more often
	pass
