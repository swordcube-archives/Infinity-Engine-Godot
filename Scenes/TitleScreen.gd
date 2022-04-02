extends Node2D

var canEnter = true
var danced = false

func _ready():
	Conductor.songPosition = 0
	Conductor.curBeat = 0
	Conductor.curStep = 0
	Conductor.change_bpm(102)
	Conductor.connect("beat_hit", self, "beat_hit")
	
	$Transition._fade_out()

func _process(delta):
	Conductor.songPosition += (delta * 1000)
	if canEnter:
		if Input.is_action_just_pressed("ui_accept"):
			canEnter = false
			
			$PressEnter.play("pressed")
			$"/root/AudioHandler".play_audio("confirmMenu")
			
			$Flash.visible = true
			var tween = Tween.new()
			tween.interpolate_property($Flash, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 2)
			add_child(tween)
			tween.start()
			
			var timer = Timer.new()
			timer.set_wait_time(2)
			add_child(timer)
			timer.start()
			timer.set_one_shot(true)
			
			yield(timer, "timeout")
			#SceneManager.transition_to_scene("MainMenu")
			$Transition.transition_to_scene("MainMenu")
			
func beat_hit():
	$Logo.frame = 0
	$Logo.play("bump")
	
	$GF.frame = 0
	if danced:
		$GF.play("danceLeft")
	else:
		$GF.play("danceRight")
		
	danced = not danced
