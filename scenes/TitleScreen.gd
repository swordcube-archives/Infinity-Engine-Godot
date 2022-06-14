extends Node2D

onready var logo = $logo
onready var gfDance = $gfDance
onready var titleText = $titleText

onready var titleQuotes = $titleQuotes
onready var ngLogo = $ngLogo

onready var cover = $cover

onready var freakyMenu:AudioStreamPlayer = AudioHandler.get_node("Music/freakyMenu")

var curWacky = ["???", "???"]

var tween = Tween.new()

func _ready():	
	get_tree().paused = false
	
	randomize()
	var txt = CoolUtil.getTXT(Paths.txt("data/introText"))
	var randomThing = txt[randi()%txt.size()]
	curWacky = randomThing.split("--")
	
	AudioHandler.playMusic("freakyMenu")
	
	Conductor.songPosition = 0.0
	Conductor.changeBPM(102)
	Conductor.connect("beatHit", self, "beatHit")
	
	titleText.play("idle")
	
	add_child(tween)
	
	if Preferences.wentThruTitle:
		Conductor.songPosition = 1000
		cover.visible = false
		titleQuotes.visible = false
	
func _process(delta):
	if freakyMenu.playing:
		Conductor.songPosition = freakyMenu.get_playback_position() * 1000
	else:
		Conductor.songPosition += (delta * 1000)
	
	if Input.is_action_just_pressed("ui_accept"):
		if not Preferences.wentThruTitle:
			skipIntro()
		else:
			titleText.play("pressed")
			AudioHandler.playSFX("confirmMenu")
			if not tween.is_active():
				cover.color = Color(1,1,1,1)
				tween.interpolate_property(cover, "color:a", 1, 0, 2)
				tween.start()
				
			yield(get_tree().create_timer(1), "timeout")
			Scenes.switchScene("MainMenu")
			get_tree().paused = false
	
var danced:bool = false
func beatHit():
	logo.frame = 0
	logo.play("bump")
	danced = !danced
	if danced:
		gfDance.frame = 0
		gfDance.play("danceLeft")
	else:
		gfDance.frame = 0
		gfDance.play("danceRight")
		
	if not Preferences.wentThruTitle:
		match Conductor.curBeat:
			1:
				titleQuotes.text = (
					"ninjamuffin" + "\n" +
					"phantomArcade" + "\n" +
					"kawaisprite" + "\n" +
					"evilsk8er"
				)
			3:
				titleQuotes.text += "\npresent"
			4:
				titleQuotes.text = ""
			5:
				titleQuotes.text = (
					"In association" + "\n" +
					"with"
				)
			7:
				titleQuotes.text += "\nNewgrounds"
				ngLogo.visible = true
			8:
				titleQuotes.text = ""
				ngLogo.visible = false
			9:
				titleQuotes.text = curWacky[0]
			11:
				for i in curWacky.size():
					if i > 0:
						titleQuotes.text += "\n" + curWacky[i]
			12:
				titleQuotes.text = ""
			13:
				titleQuotes.text = "Friday"
			14:
				titleQuotes.text += "\nNight"
			15:
				titleQuotes.text += "\nFunkin"
			16:
				skipIntro()
			
func skipIntro():
	Preferences.wentThruTitle = true
	
	titleQuotes.visible = false
	ngLogo.visible = false
	
	cover.color = Color(1,1,1,1)
	tween.interpolate_property(cover, "color:a", 1, 0, 4)
	tween.start()
