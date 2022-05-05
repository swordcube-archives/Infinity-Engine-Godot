extends Node2D

onready var gf = $GF/AnimatedSprite
onready var logo = $Logo/AnimatedSprite

func _ready():
	AudioHandler.play_music("freakyMenu")
	
	Conductor.change_bpm(102)
	Conductor.song_position = 0
	Conductor.connect("beat_hit", self, "beat_hit")
	dance()
	
func _physics_process(delta):
	Conductor.song_position += (delta * 1000)
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		SceneHandler.switch_to("MainMenu")
	
func beat_hit():
	dance()
	
var danced = false
func dance():
	danced = !danced
	logo.frame = 0
	logo.play("logo bumpin")
	if danced:
		gf.frame = 0
		gf.play("danceLeft")
	else:
		gf.frame = 0
		gf.play("danceRight")
