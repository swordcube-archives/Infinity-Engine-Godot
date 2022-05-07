extends Node2D

onready var gf = $GF/AnimatedSprite
onready var logo = $Logo/AnimatedSprite
onready var godot = $IntroText/GodotLogo

var skipped = false

var curWacky = ["???", "???"]

func _ready():
	var txt = CoolUtil.get_txt(Paths.txt("Data/IntroText"))
	
	curWacky = txt[int(rand_range(0, len(txt) - 1))].split("--")
	
	AudioHandler.play_music("freakyMenu")
	
	Conductor.change_bpm(102)
	Conductor.song_position = 0
	Conductor.connect("beat_hit", self, "beat_hit")
	dance()
	
	if GameplaySettings.skip_title:
		skip_intro()
	
func _physics_process(delta):
	if AudioHandler.freakyMenu.playing:
		Conductor.song_position = (AudioHandler.freakyMenu.get_playback_position() * 1000)
	else:
		Conductor.song_position += (delta * 1000)
		
var going:bool = false
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		skip_intro()
		
		if not going:
			going = true
			
			var bg = $IntroText/BG
			var flash = $IntroText/Flash
			
			AudioHandler.play_audio("confirmMenu")
			$EnterText/AnimationPlayer.play("confirm")
			
			if flash.modulate.a <= 0 or skipped:
				flash.modulate.a = 1
				var tween = Tween.new()
				add_child(tween)
				tween.interpolate_property(flash, "modulate", flash.modulate, Color(1, 1, 1, 0), 2)
				tween.start()
				
			yield(get_tree().create_timer(2), "timeout")
			SceneHandler.switch_to("MainMenu")
	
func beat_hit():
	dance()
	
	if not skipped:
		match Conductor.cur_beat:
			1:
				create_cool_text(["swordcube", "Leather128"])
			3:
				add_more_text("present")
			4:
				delete_cool_text()
			5:
				create_cool_text(["In association", "with"])
			7:
				add_more_text("Godot Engine")
				godot.visible = true
			8:
				delete_cool_text()
				godot.visible = false
			9:
				add_more_text(curWacky[0])
			11:
				add_more_text(curWacky[1])
			12:
				delete_cool_text()
			13:
				add_more_text("Friday")
			14:
				add_more_text("Night")
			15:
				add_more_text("Funkin")
			16:
				skip_intro()
	
var danced = false

func dance():
	danced = !danced
	logo.frame = 0
	logo.play("logo bumpin")
	if danced:
		gf.frame = 0
		gf.play("danceLeft")
	else:
		gf.frame = 0
		gf.play("danceRight")
		
func create_cool_text(text = []):
	var result = ""
	
	for shit in text:
		result += shit + "\n"

	$IntroText/Label.text = result
	
func add_more_text(text):
	$IntroText/Label.text += text + "\n"
	
func delete_cool_text():
	$IntroText/Label.text = ""
		
func skip_intro():
	skipped = true
	GameplaySettings.skip_title = true
	
	$IntroText/Label.visible = false
	
	var bg = $IntroText/BG
	var flash = $IntroText/Flash
	
	flash.visible = true
	bg.visible = false
	
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(flash, "modulate", flash.modulate, Color(1, 1, 1, 0), 2)
	tween.start()
