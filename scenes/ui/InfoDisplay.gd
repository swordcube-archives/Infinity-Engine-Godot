extends CanvasLayer

onready var currentFPS:int = 0

onready var memoryUsage:int = 0
onready var memoryPeak:int = 0

onready var vramUsage:int = 0
onready var vramPeak:int = 0

onready var label = $Label

var dumb_timer = Timer.new()

func _ready() -> void:
	add_child(dumb_timer)
	
	dumb_timer.one_shot = false
	dumb_timer.start(0.25)
	dumb_timer.connect("timeout", self, "update_cum_balls_in_yo_mama")

func update_cum_balls_in_yo_mama():
	label.visible = Preferences.getOption("fps-counter")
	currentFPS = Performance.get_monitor(Performance.TIME_FPS)
	
	if OS.is_debug_build():
		memoryUsage = Performance.get_monitor(Performance.MEMORY_STATIC)
		memoryPeak = Performance.get_monitor(Performance.MEMORY_STATIC_MAX) 
	
	vramUsage = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	if vramUsage > vramPeak:
		vramPeak = vramUsage
	
	label.text = "FPS: " + str(currentFPS)
	if OS.is_debug_build():
		label.text += "\nMEM: " + CoolUtil.getSizeLabel(memoryUsage) + " / " + CoolUtil.getSizeLabel(memoryPeak)
		
	label.text += "\nVRAM: " + CoolUtil.getSizeLabel(vramUsage) + " / " + CoolUtil.getSizeLabel(vramPeak)
