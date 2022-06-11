extends Event

var duration_left: float = 0.0
var intensity: float = 0.0

var hud_duration_left: float = 0.0
var hud_intensity: float = 0.0

var camera:Node
var hud:Node

func process_event(arguemnt_1, argument_2):
	var values = [
		arguemnt_1.split(","),
		argument_2.split(",")
	]
	
	shake(float(values[0][1]), float(values[0][0]), false)
	shake(float(values[1][1]), float(values[1][0]), true)

func _ready():
	randomize()

func shake(_intensity: float, _duration: float, is_hud: bool = false):
	camera = game.camera
	hud = game.ui
	
	if !is_hud:
		duration_left = _duration
		intensity = _intensity
	else:
		hud_duration_left = _duration
		hud_intensity = _intensity

func _physics_process(delta):
	if duration_left > 0:
		duration_left -= delta
		
		if duration_left <= 0:
			camera.offset = Vector2(0,0)
		
		if duration_left > 0:
			camera.offset.x = rand_range(-intensity * 1280, intensity * 1280) * (1 + (1 - camera.zoom.x))
			camera.offset.y = rand_range(-intensity * 720, intensity * 720) * (1 + (1 - camera.zoom.y))
	
	if hud_duration_left > 0:
		hud_duration_left -= delta
		
		if hud_duration_left <= 0:
			hud.offset = Vector2(-650 * (game.defaultHudZoom - 1), -400 * (game.defaultHudZoom - 1))
		
		if hud_duration_left > 0:
			hud.offset.x = (-650 * (hud.scale.x - 1)) + rand_range(-hud_intensity * 1280, hud_intensity * 1280) * hud.scale.x
			hud.offset.y = (-400 * (hud.scale.y - 1)) +rand_range(-hud_intensity * 720, hud_intensity * 720) * hud.scale.y
