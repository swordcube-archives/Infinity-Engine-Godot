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
			$Countdown.stream = load("res://Assets/Sounds/intro3.ogg")
		1:
			$Countdown.stream = load("res://Assets/Sounds/intro2.ogg")
		2:
			$Countdown.stream = load("res://Assets/Sounds/intro1.ogg")
		3:
			$Countdown.stream = load("res://Assets/Sounds/introGo.ogg")
			
	$Countdown.play()
