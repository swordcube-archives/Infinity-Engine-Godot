extends Label

func _process(delta):
	text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
	
	Performance.get_monitor(Performance.MEMORY_STATIC)
	
	var mem = Performance.get_monitor(Performance.MEMORY_STATIC) / 100000
	var mem_peak = Performance.get_monitor(Performance.MEMORY_STATIC_MAX) / 100000
	var vram = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 100000
	
	if mem > 0 and mem_peak > 0:
		text += "\nMEM: " + str(round(mem) / 10) + " MB"
		text += "\nMEM peak: " + str(round(mem_peak) / 10) + " MB"
		
	text += "\nVRAM: " + str(round(vram) / 10) + " MB"
