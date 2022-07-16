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
	
	if Preferences.getOption("first-time-setup"):
		Scenes.switchScene("FirstTimeSetup", false)
		return
	
	randomize()
	var txt = CoolUtil.getTXT(Paths.txt("data/introText"))
	var randomThing = txt[randi()%txt.size()]
	curWacky = randomThing.split("--")
	
	AudioHandler.playMusic("freakyMenu")
	
	Conductor.songPosition = 0.0
	Conductor.changeBPM(102)
	Conductor.connect("beatHit", self, "beatHit")
	
	titleText.play("idle")
	
	$AnimationPlayer.play("default")
	add_child(tween)
	
	if Preferences.wentThruTitle:
		Conductor.songPosition = 1000
		cover.visible = false
		titleQuotes.visible = false
		
	yield(get_tree().create_timer(1), "timeout")
	Discord.update_presence("In the Title Screen")
		
var confirmed:bool = false
	
func _process(delta):
	if freakyMenu.playing:
		Conductor.songPosition = freakyMenu.get_playback_position() * 1000
	else:
		Conductor.songPosition += (delta * 1000)
		
	if OS.is_debug_build() and Input.is_action_just_pressed("ui_focus_next"):
		var day = str(OS.get_datetime()["day"])
		var month = str(OS.get_datetime()["month"])
		var year = str(OS.get_datetime()["year"])
		year.erase(0, 2)
		
		if len(day) < 2:
			day = "0"+day
			
		if len(month) < 2:
			month = "0"+month
		
		var combined = day + month + year
		var f = File.new()
		var error = f.open(Paths.txt("data/gameVersionDate"), File.WRITE)
		if error == OK:
			f.store_string(combined)
			f.close()
			print("FILE SAVED!")
		else:
			print("ERROR OCCURED WHILE SAVING GAME VERSION DATE!")
			
	if Preferences.wentThruTitle:
		var multThingie:float = (delta * 0.5)
		if Input.is_action_pressed("ui_left"):
			logo.material.set("shader_param/hue", logo.material.get("shader_param/hue") - multThingie)
			gfDance.material.set("shader_param/hue", gfDance.material.get("shader_param/hue") - multThingie)
			
		if Input.is_action_pressed("ui_right"):
			logo.material.set("shader_param/hue", logo.material.get("shader_param/hue") + multThingie)
			gfDance.material.set("shader_param/hue", gfDance.material.get("shader_param/hue") + multThingie)
	
	if Input.is_action_just_pressed("ui_accept"):
		if not Preferences.wentThruTitle:
			skipIntro()
		else:
			if not confirmed:
				confirmed = true
				if not Preferences.getOption("photosensitive"):
					titleText.play("pressed")
				AudioHandler.playSFX("confirmMenu")
				if not tween.is_active():
					cover.visible = true
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
