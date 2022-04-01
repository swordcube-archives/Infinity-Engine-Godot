extends Label

func _process(delta):
	text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
