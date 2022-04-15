extends Node

var PlayState = null
var fuck = 0.0

onready var o_strums = PlayState.get_node("camHUD/OpponentStrums")
onready var p_strums = PlayState.get_node("camHUD/PlayerStrums")

onready var window_pos = OS.window_position

func _ready():
	# this makes beat_hit and step_hit actual functions
	#Conductor.connect("beat_hit", self, "beat_hit")
	#Conductor.connect("step_hit", self, "step_hit")
	pass
	
func opponent_note_hit(noteData):
	pass
	
func player_note_hit(noteData):
	pass
	
func _physics_process(delta): # this is the update function, runs every frame.
	if not PlayState.countdown_active:
		fuck += (delta * 5) * Gameplay.song_multiplier
		
		OS.window_position.y = window_pos.y - 10 + (sin(fuck / 2) + 1) * 10
		
		PlayState.health = (sin(fuck / 3.5) + 2) * 0.5
		
		var index = 0
		o_strums.global_position.x = lerp(o_strums.global_position.x, -600, delta * 2)
		p_strums.global_position.x = lerp(p_strums.global_position.x, ScreenRes.screen_width / 2.72, delta * 2)
		for strum in p_strums.get_children():
			strum.position.y = sin(fuck + index) * 30
			index += 1
	
func _beat_hit(): # this is a function that runs every beat
	pass
	
func _step_hit(): # this is _beat_hit but it happens more often
	pass
	
func screen_center(object):
	print(ScreenRes.screen_width)
	print(ScreenRes.screen_height)
	object.global_position = Vector2(ScreenRes.screen_width / 2, ScreenRes.screen_height / 2)
