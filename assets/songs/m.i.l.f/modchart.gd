extends Modchart

onready var camera = $"../".camera
onready var hud = $"../".HUD

func beat_hit():
	if Conductor.curBeat >= 168 and Conductor.curBeat < 200:
		camera.zoom -= Vector2(0.015, 0.015)
		hud.scale += Vector2(0.03, 0.03)
		hud.offset += Vector2(-22.5, -15)
