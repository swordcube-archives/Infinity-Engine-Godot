extends Node2D

func play_audio(name, pos = null):
	if pos != null:
		get_node(name).play(pos)
	else:
		get_node(name).play()
	
func pause_audio(name):
	get_node(name).pause()
	
func stop_audio(name):
	get_node(name).stop()
	
func play_hitsound(name):
	if name != "None":
		get_node("Hitsounds").get_node(name).play(0)

# song bullshit

# loading

func play_inst(name):
	$Inst.stream = load(Paths.inst(name))
	$Inst.play()
	
func play_voices(name):
	$Voices.stream = load(Paths.voices(name))
	$Voices.play()
	
# misc
	
func pause_inst():
	$Inst.stop()
	
func unpause_inst():
	$Inst.play()
	
func stop_inst():
	$Inst.stop()
	
# misc but for voices
	
func pause_voices():
	$Voices.stop()
	
func unpause_voices():
	$Voices.play()
	
func stop_voices():
	$Voices.stop()
	
# countdown shit
func play_countdown(num):
	match num:
		3:
			var sound = get_node("intro3-" + Gameplay.ui_Skin.to_lower())
			
			if sound == null:
				sound = get_node("intro3-default")
				
			sound.play()
			sound.seek(0)
		2:
			var sound = get_node("intro2-" + Gameplay.ui_Skin.to_lower())

			if sound == null:
				sound = get_node("intro2-default")
			
			sound.play()
			sound.seek(0)
		1:
			var sound = get_node("intro1-" + Gameplay.ui_Skin.to_lower())

			if sound == null:
				sound = get_node("intro1-default")
			
			sound.play()
			sound.seek(0)
		0:
			var sound = get_node("introGo-" + Gameplay.ui_Skin.to_lower())

			if sound == null:
				sound = get_node("introGo-default")
			
			sound.play()
			sound.seek(0)
