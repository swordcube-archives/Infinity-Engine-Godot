extends Node2D

onready var keybindsMenu = $KeybindsMenu
onready var offsetAudio = $AudioOffsetTest

onready var offsetText = $DoOffsetShit/CurrentOffset/
onready var offsetTextAgain = $DoNoTapOffsetShit/ProgressBar/CurrentOffset

onready var offsetBar = $DoNoTapOffsetShit/ProgressBar

onready var offsetStrum = $DoOffsetShit/Strum

onready var funnyStrums:Array = [
	$ScrollTypeShit/Opponent,
	$ScrollTypeShit/Player
]

var tween = Tween.new()

var changedBinds:bool = false

var offsetState:String = ""

var offsetArray:Array = []
var addedOffsets:Array = []

var currentOffset:float = 0.0

func _init():
	PlayStateSettings.getSkin()

func _ready():
	Conductor.changeBPM(120)
	
	var note:Node2D = load("res://scenes/firsttimesetup/Note.tscn").instance()
	
	for i in 32:
		var time:float = (Conductor.timeBetweenBeats * i)+AudioServer.get_output_latency()*1000.0
		offsetArray.append(time)
		
		var newNote = note.duplicate()
		newNote.strumTime = time
		offsetStrum.add_child(newNote)
	
	add_child(tween)
	keybindsMenu.keyCount = 4
	$KeybindsMenu/BG.visible = false
	
	$Initial.visible = true
	
func changeOffset(amount:int = 0):
	currentOffset += amount
	currentOffset = clamp(currentOffset, -1000, 1000)
	offsetTextAgain.text = "Current Offset: "+str(currentOffset)+"ms"
	offsetBar.value = currentOffset
	yield(get_tree().create_timer(0.1), "timeout")
	
func _process(delta):
	Conductor.songPosition = offsetAudio.get_playback_position()*1000.0
	if not is_instance_valid(keybindsMenu) and not changedBinds:
		changedBinds = true
		yield(get_tree().create_timer(0.5), "timeout")
		$WannaDoYourMom.modulate.a = 0
		$WannaDoYourMom.visible = true
		tween.interpolate_property($WannaDoYourMom, "modulate:a", 0, 1, 1)
		tween.start()
		
	if Preferences.getOption("centered-notes"):
		funnyStrums[0].position.x = lerp(funnyStrums[0].position.x, -640, MathUtil.getLerpValue(0.4, delta))
		funnyStrums[1].position.x = lerp(funnyStrums[1].position.x, 640, MathUtil.getLerpValue(0.4, delta))
	else:
		var xMult:float = 315
		funnyStrums[0].position.x = lerp(funnyStrums[0].position.x, xMult, MathUtil.getLerpValue(0.4, delta))
		funnyStrums[1].position.x = lerp(funnyStrums[1].position.x, xMult + (CoolUtil.screenWidth/2), MathUtil.getLerpValue(0.4, delta))
		
	if Preferences.getOption("downscroll"):
		funnyStrums[0].position.y = 550
		funnyStrums[1].position.y = 550
	else:
		funnyStrums[0].position.y = 50
		funnyStrums[1].position.y = 50
		
	match offsetState:
		"arrows":
			if Input.is_action_pressed("ui_shift"):
				if Input.is_action_pressed("ui_left"):
					changeOffset(-1)
					
				if Input.is_action_pressed("ui_right"):
					changeOffset(1)
			else:
				if Input.is_action_just_pressed("ui_left"):
					changeOffset(-1)
					
				if Input.is_action_just_pressed("ui_right"):
					changeOffset(1)
		"tap":
			if offsetArray.size() > 0:
				var note = offsetArray[0]
				if Input.is_action_just_pressed("ui_space"):
					var time:int = floor(Conductor.songPosition - note)
					addedOffsets.append(time)
					
					offsetStrum.remove_child(offsetStrum.get_child(0))
					currentOffset = 0.0
					
					for offset in addedOffsets:
						currentOffset += offset/addedOffsets.size()
					
					offsetText.text = "Current Offset: "+str(currentOffset)+"ms"
					offsetArray.remove(0)

func _on_CancelSetup_pressed():
	AudioHandler.playSFX("cancelMenu")
	$Fade.visible = true
	tween.interpolate_property($Fade, "modulate:a", 0, 1, 2)
	tween.start()
	yield(get_tree().create_timer(2.5), "timeout")
	Preferences.setOption("first-time-setup", false)
	Preferences.wentThruTitle = false
	Scenes.switchScene("TitleScreen", true)

func _on_StartSetup_pressed():
	tween.interpolate_property($Initial, "modulate:a", 1, 0, 0.5)
	tween.start()
	
	yield(get_tree().create_timer(1), "timeout")
	keybindsMenu.modulate.a = 0
	keybindsMenu.visible = true
	
	tween.interpolate_property(keybindsMenu, "modulate:a", 0, 1, 0.5)
	tween.start()

func _on_ArrowsOffset_pressed():
	tween.interpolate_property($WannaDoYourMom, "modulate:a", 1, 0, 1)
	tween.start()
	yield(get_tree().create_timer(1), "timeout")
	$WannaDoYourMom.visible = false
	
	$DoNoTapOffsetShit.modulate.a = 0
	$DoNoTapOffsetShit.visible = true
	
	tween.interpolate_property($DoNoTapOffsetShit, "modulate:a", 0, 1, 1)
	tween.start()
	offsetState = "arrows"

func _on_TapOffset_pressed():
	tween.interpolate_property($WannaDoYourMom, "modulate:a", 1, 0, 1)
	tween.start()
	yield(get_tree().create_timer(1), "timeout")
	$WannaDoYourMom.visible = false
	
	$DoOffsetShit.modulate.a = 0
	$DoOffsetShit.visible = true

	tween.interpolate_property($DoOffsetShit, "modulate:a", 0, 1, 1)
	tween.start()
	yield(get_tree().create_timer(1), "timeout")
	offsetState = "tap"
	offsetAudio.play()
	yield(get_tree().create_timer(offsetAudio.stream.get_length()), "timeout")
	print("OFFSET DONE!")
	offsetState = ""
	yield(get_tree().create_timer(0.5), "timeout")
	tween.interpolate_property($DoOffsetShit, "modulate:a", 1, 0, 1)
	tween.start()
	yield(get_tree().create_timer(1), "timeout")
	$DoOffsetShit.visible = false
	
	$ScrollTypeShit.modulate.a = 0
	$ScrollTypeShit.visible = true
	
	tween.interpolate_property($ScrollTypeShit, "modulate:a", 0, 1, 1)
	tween.start()

func _on_FuckYouOffset_pressed():
	AudioHandler.playSFX("cancelMenu")
	tween.interpolate_property($WannaDoYourMom, "modulate:a", 1, 0, 1)
	tween.start()
	yield(get_tree().create_timer(1), "timeout")
	$WannaDoYourMom.visible = false
	
	$ScrollTypeShit.modulate.a = 0
	$ScrollTypeShit.visible = true
	
	tween.interpolate_property($ScrollTypeShit, "modulate:a", 0, 1, 1)
	tween.start()

func _on_ArrowOffsetContinue_pressed():
	tween.interpolate_property($DoNoTapOffsetShit, "modulate:a", 1, 0, 1)
	tween.start()
	offsetState = ""
	yield(get_tree().create_timer(1), "timeout")
	$DoNoTapOffsetShit.visible = false
	
	$ScrollTypeShit.modulate.a = 0
	$ScrollTypeShit.visible = true
	
	tween.interpolate_property($ScrollTypeShit, "modulate:a", 0, 1, 1)
	tween.start()
	
func _on_Downscroll_pressed():
	Preferences.setOption("downscroll", $ScrollTypeShit/Downscroll.pressed)

func _on_CenteredNotes_pressed():
	Preferences.setOption("centered-notes", $ScrollTypeShit/CenteredNotes.pressed)

func _on_Done_pressed():
	tween.interpolate_property($ScrollTypeShit, "modulate:a", 1, 0, 1)
	tween.start()
	yield(get_tree().create_timer(1), "timeout")
	$ScrollTypeShit.visible = false
	
	$Photosensitive.modulate.a = 0
	$Photosensitive.visible = true
	
	tween.interpolate_property($Photosensitive, "modulate:a", 0, 1, 1)
	tween.start()

func _on_PhotoYes_pressed():
	Preferences.setOption("photosensitive", true)
	_on_CancelSetup_pressed()
	
	Preferences.setOption("note-offset", currentOffset)

func _on_PhotoNo_pressed():
	Preferences.setOption("photosensitive", false)
	_on_CancelSetup_pressed()
	
	Preferences.setOption("note-offset", currentOffset)
