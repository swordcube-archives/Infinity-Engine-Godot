extends Event

func on_event():
	var world_zoom:float = float(params["World Zoom"])
	var hud_zoom:float = float(params["HUD Zoom"])

	print(world_zoom)
	print(hud_zoom)
