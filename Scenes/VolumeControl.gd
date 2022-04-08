extends CanvasLayer

var volume = 0
var muted = false

var timer:float = 1.0

func init():
	volume = Options.get_data("volume")
	muted = Options.get_data("muted")

func _process(delta):
	timer += delta
	
	if Input.is_action_just_pressed("volume_down"):
		AudioHandler.play_audio("beep")
		
		volume -= 5
		timer = -1
		
		if volume == -50:
			muted = true
		else:
			muted = false
			
		if volume > 0:
			volume = 0
		if volume < -50:
			volume = -50
			
		Options.set_data("volume", volume)
		Options.set_data("muted", muted)
		
	if Input.is_action_just_pressed("volume_up"):
		AudioHandler.play_audio("beep")
		
		volume += 5
		timer = -1
		
		if volume == -50:
			muted = true
		else:
			muted = false
			
		if volume > 0:
			volume = 0
		if volume < -50:
			volume = -50
			
		Options.set_data("volume", volume)
		Options.set_data("muted", muted)
		
	if Input.is_action_just_pressed("volume_switch"):
		AudioHandler.play_audio("beep")
		
		muted = !muted
		timer = -1
		
		Options.set_data("muted", muted)
		
	var volume_percent = (100 + (volume * 2)) / 10
	
	for child in $Bars.get_children():
		if float(child.name) <= volume_percent and !muted:
			child.color = Color(1,1,1,1)
		else:
			child.color = Color(1,1,1,0.5)
	
	if timer > 0.5:
		offset.y -= delta * 350
		
		if offset.y < -80:
			offset.y = -80
	else:
		offset.y = 0
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)
		
