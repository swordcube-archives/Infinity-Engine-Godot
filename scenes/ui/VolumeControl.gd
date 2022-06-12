extends CanvasLayer

var volume = Preferences.getOption("volume")
onready var muted = Preferences.getOption("muted")

onready var bg = $BG
onready var bits = $BG/Bits
var tween = Tween.new()

func _init():
	add_child(tween)
	set_vol()
	
func set_muted():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)
	
func set_vol():
	if bg != null:
		tween.stop_all()
		bg.rect_position.y = 0
		tween.interpolate_property(bg, "rect_position:y", 0, -bg.rect_size.y, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT, 1)
		tween.start()
		
	if bits:
		for child in bits.get_children():
			if int(child.name) <= volume and !muted:
				child.color.a = 1
			else:
				child.color.a = 0.5
			
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), (volume - 9) * 5)

func _input(event):
	if Input.is_action_just_pressed("volume_up"):
		volume += 1
		if volume > 9:
			volume = 9
			set_muted()
			
		Preferences.setOption("volume", volume)
		set_vol()
		AudioHandler.playSFX("flixelBeep")
			
	if Input.is_action_just_pressed("volume_down"):
		volume -= 1
		if volume < -1:
			volume = -1
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
			
		Preferences.setOption("volume", volume)
		set_vol()
		AudioHandler.playSFX("flixelBeep")
		
	if Input.is_action_just_pressed("volume_switch"):
		muted = !muted
		Preferences.setOption("muted", muted)
		if volume <= -1:
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
			set_vol()
		else:
			set_muted()
			set_vol()
			
		AudioHandler.playSFX("flixelBeep")
