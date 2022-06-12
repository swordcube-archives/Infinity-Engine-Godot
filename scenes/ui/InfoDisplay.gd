extends CanvasLayer

onready var currentFPS:int = 0

onready var memoryUsage:int = 0
onready var memoryPeak:int = 0

onready var vramUsage:int = 0
onready var vramPeak:int = 0

onready var label = $Label

func _process(delta):
	currentFPS = Performance.get_monitor(Performance.TIME_FPS)
	
	if OS.is_debug_build():
		memoryUsage = Performance.get_monitor(Performance.MEMORY_STATIC) / 1000000
		memoryPeak = Performance.get_monitor(Performance.MEMORY_STATIC_MAX) / 1000000
	
	vramUsage = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1000000
	if vramUsage > vramPeak:
		vramPeak = vramUsage
	
	label.text = "FPS: " + str(currentFPS)
	if OS.is_debug_build():
		label.text += "\nMEM: " + str(round(memoryUsage) / 10) + "mb / " + str(round(memoryPeak) / 10) + "mb"
		
	label.text += "\nVRAM: " + str(round(vramUsage) / 10) + "mb / " + str(round(vramPeak) / 10) + "mb"
