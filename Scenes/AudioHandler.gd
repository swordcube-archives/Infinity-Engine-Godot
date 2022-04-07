extends Node2D

func play_audio(name):
	get_node(name).play()
	
func pause_audio(name):
	get_node(name).pause()
	
func stop_audio(name):
	get_node(name).stop()

# song bullshit

# loading

func play_inst(name):
	$Inst.stream = load("res://Assets/Songs/" + name + "/Inst.ogg")
	$Inst.play()
	
func play_voices(name):
	$Voices.stream = load("res://Assets/Songs/" + name + "/Voices.ogg")
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
		0:
			var sound = get_node("intro3-" + Gameplay.ui_Skin.to_lower())
			
			sound.play()
			sound.seek(0)
		1:
			var sound = get_node("intro2-" + Gameplay.ui_Skin.to_lower())
			
			sound.play()
			sound.seek(0)
		2:
			var sound = get_node("intro1-" + Gameplay.ui_Skin.to_lower())
			
			sound.play()
			sound.seek(0)
		3:
			var sound = get_node("introGo-" + Gameplay.ui_Skin.to_lower())
			
			sound.play()
			sound.seek(0)
