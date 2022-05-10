extends KinematicBody2D

var velocity:Vector2 = Vector2()

onready var sprite = $Sprite

func _ready():
	randomize()
	
	velocity.x = rand_range(-1000, 1000)
	velocity.y = rand_range(-1000, 1000)
	
	position = Vector2(rand_range(0, 1280), rand_range(0, 720))

func _physics_process(_delta):
	move_and_slide(velocity, Vector2.UP)
	
	if (position.x <= 0 or position.x >= 1280) and (position.y <= 0 or position.y >= 720) and floor(rand_range(0, 1000)) == 266:
		OS.shell_open("https://godotengine.org")
		
		AudioHandler.inst.stop()
		AudioHandler.voices.stop()
		SceneHandler.switch_to("FreeplayMenu")
	
	if position.x <= 0 or position.x >= 1280 or get_last_slide_collision():
		velocity.x *= -rand_range(0.5, 1)
		scale = Vector2(rand_range(0.8, 1.2), rand_range(0.8, 1.2))
	if position.y <= 0 or position.y >= 720 or get_last_slide_collision():
		velocity.y *= -rand_range(0.5, 1)
		scale = Vector2(rand_range(0.8, 1.2), rand_range(0.8, 1.2))
	
	if abs(velocity.x) <= 100:
		velocity.x = rand_range(-1000, 1000)
	if abs(velocity.y) <= 100:
		velocity.y = rand_range(-1000, 1000)
	
	position.x = clamp(position.x, 0, 1280)
	position.y = clamp(position.y, 0, 720)
