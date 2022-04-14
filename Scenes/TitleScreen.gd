extends Node2D

var canEnter = true
var danced = false

var skipped = false

var curWacky = ["???", "???"]

var tween = Tween.new()

func _ready():
	var txt = Util.get_txt(Paths.txt("Data/IntroText"))
	
	curWacky = txt[int(rand_range(0, len(txt) - 1))].split("--")
	
	if not AudioHandler.get_node("freakyMenu").playing:
		AudioHandler.play_audio("freakyMenu")
	
	Conductor.songPosition = 0
	Conductor.curBeat = 0
	Conductor.curStep = 0
	Conductor.change_bpm(102)
	Conductor.connect("beat_hit", self, "beat_hit")
	
	if Gameplay.skipped_title:
		skipIntro(true)
	
	$Transition._fade_out()

func _process(delta):
	if AudioHandler.get_node("freakyMenu").playing:
		Conductor.songPosition = (AudioHandler.get_node("freakyMenu").get_playback_position() * 1000)
	else:
		Conductor.songPosition += (delta * 1000)
		
	if canEnter:
		if Input.is_action_just_pressed("ui_accept"):
			if skipped:
				canEnter = false
				
				$PressEnter.play("pressed")
				AudioHandler.play_audio("confirmMenu")
				
				if $Flash.modulate.a <= 0:
					remove_child(tween)
					tween = Tween.new()
					$Flash.visible = true
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
			else:
				skipIntro()	
			
func beat_hit():
	$Logo.frame = 0
	$Logo.play("bump")
	
	$GF.frame = 0
	if danced:
		$GF.play("danceLeft")
	else:
		$GF.play("danceRight")
		
	danced = not danced
	
	# intro text bullshit
	if not skipped:
		match Conductor.curBeat:
			1:
				createCoolText(["swordcube", "Leather128"])
			3:
				addMoreText("present")
			4:
				deleteCoolText()
			5:
				createCoolText(["In association", "with"])
			7:
				addMoreText("Godot Engine")
				$GodotLogo.visible = true
			8:
				deleteCoolText()
				$GodotLogo.visible = false
			9:
				addMoreText(curWacky[0])
			11:
				addMoreText(curWacky[1])
			12:
				deleteCoolText()
			13:
				addMoreText("Friday")
			14:
				addMoreText("Night")
			15:
				addMoreText("Funkin")
			16:
				skipIntro()
			
func skipIntro(skip_flash = false):
	Gameplay.skipped_title = true
	
	skipped = true
	
	$IntroText.visible = false
	$GodotLogo.visible = false
	
	$Cover.visible = false
	if not skip_flash:
		$Flash.visible = true
		
		remove_child(tween)
		tween = Tween.new()
		tween.interpolate_property($Flash, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 2)
		add_child(tween)
		tween.start()
	else:
		$Flash.modulate.a = 0
			
func createCoolText(text = []):
	var result = ""
	
	for shit in text:
		result += shit + "\n"

	$IntroText.text = result
	
func addMoreText(text):
	$IntroText.text += text + "\n"
	
func deleteCoolText():
	$IntroText.text = ""
