extends CanvasLayer

onready var fps_text = $Label
onready var debug:bool = OS.is_debug_build()

# Timestamps of frames rendered in the last second
var times := []

var fps := 0

var vram:float = 0.0

var mem:float = 0.0
var mem_peak:float = 0.0

func _process(delta):
	var now := OS.get_ticks_msec()

	# Remove frames older than 1 second in the `times` array
	while times.size() > 0 and times[0] <= now - 1000:
		times.pop_front()

	times.append(now)
	fps = times.size()
	
	vram = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 100000
	
	fps_text.text = "FPS: " + str(fps)
	
	if debug:
		mem = Performance.get_monitor(Performance.MEMORY_STATIC) / 100000
		mem_peak = Performance.get_monitor(Performance.MEMORY_STATIC_MAX) / 100000
		
		fps_text.text += "\nMEM: " + str(round(mem) / 10) + " MB"
		fps_text.text += "\nMEM Peak: " + str(round(mem_peak) / 10) + " MB"
	
	fps_text.text += "\nVRAM: " + str(round(vram) / 10) + " MB"
