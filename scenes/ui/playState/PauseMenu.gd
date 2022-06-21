extends Node2D

var alphabet = load("res://scenes/ui/pauseMenu/PauseOption.tscn").instance()

onready var options = $Options

var defaultPauseOptions:Array = [
	"Resume",
	"Restart Song",
	"Change Difficulty",
	"Toggle Practice Mode",
	"Options",
	"Exit to Menu",
]

var changingDifficulty:bool = false

var curSelected:int = 0
var pauseOptions:Array = defaultPauseOptions

var tween:Tween = Tween.new()

onready var breakfast:AudioStreamPlayer = AudioHandler.get_node("Music/breakfast")

func _ready():
	breakfast.pitch_scale = 1.0
	breakfast.volume_db = -50
	breakfast.play()
	
	$SongName.text = PlayStateSettings.SONG.song.song
	$DiffText.text = PlayStateSettings.difficulty.to_upper()
	$DeathsText.text = "Blueballed: " + str(PlayStateSettings.deaths)
	$PracticeModeText.visible = PlayStateSettings.practiceMode
	
	add_child(tween)
	tween.interpolate_property($BG, "color:a", 0, 0.6, 0.4, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	tweenTextThingie($SongName, 0.3)
	tweenTextThingie($DiffText, 0.5)
	tweenTextThingie($DeathsText, 0.7)
	tweenTextThingie($PracticeModeText, 0.9)
	tween.interpolate_property(breakfast, "volume_db", breakfast.volume_db, 0, breakfast.stream.get_length() / 2)
	tween.start()
	
	spawnOptions()
	changeSelection()
	
func _process(delta):
	AudioHandler.inst.stop()
	AudioHandler.voices.stop()
	
	if Input.is_action_just_pressed("ui_up"):
		changeSelection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		changeSelection(1)
		
	if Input.is_action_just_pressed("ui_accept"):
		if changingDifficulty:
			match pauseOptions[curSelected]:
				"Back":
					curSelected = 0
					pauseOptions = defaultPauseOptions
					spawnOptions()
					changeSelection()
					changingDifficulty = false
				_:
					PlayStateSettings.difficulty = pauseOptions[curSelected]
					PlayStateSettings.SONG = CoolUtil.getJSON(Paths.songJSON(PlayStateSettings.SONG.song.song, PlayStateSettings.difficulty))
					changingDifficulty = false
					queue_free()
					Scenes.switchScene("PlayState")
		else:
			match pauseOptions[curSelected]:
				"Resume":
					tween.stop_all()
					tween.queue_free()
					breakfast.volume_db = -50
					breakfast.stop()
					get_tree().paused = false
					queue_free()
					
					AudioHandler.inst.play(Conductor.songPosition / 1000.0)
					AudioHandler.voices.play(Conductor.songPosition / 1000.0)
				"Restart Song":
					breakfast.volume_db = -50
					breakfast.stop()
					queue_free()
					Scenes.switchScene("PlayState")
				"Change Difficulty":
					curSelected = 0
					pauseOptions = PlayStateSettings.availableDifficulties.duplicate()
					pauseOptions.append("Back")
					spawnOptions()
					changeSelection()
					changingDifficulty = true
				"Toggle Practice Mode":
					if not PlayStateSettings.practiceMode:
						PlayStateSettings.usedPractice = true
					PlayStateSettings.practiceMode = !PlayStateSettings.practiceMode
					$PracticeModeText.visible = PlayStateSettings.practiceMode
				"Options":
					breakfast.volume_db = -50
					breakfast.stop()
					PlayStateSettings.goBackToOptionsFromPause = true
					queue_free()
					Scenes.switchScene("OptionsMenu")
					AudioHandler.playMusic("optionsMenu")
				"Exit to Menu":
					breakfast.volume_db = -50
					breakfast.stop()
					queue_free()
					AudioHandler.playMusic("freakyMenu")
					if PlayStateSettings.storyMode:
						Scenes.switchScene("StoryMenu")
					else:
						Scenes.switchScene("FreeplayMenu")
	
func changeSelection(change:int = 0):
	curSelected += change
	if curSelected < 0:
		curSelected = options.get_child_count() - 1
	if curSelected > options.get_child_count() - 1:
		curSelected = 0
		
	for i in options.get_child_count():
		var o = options.get_child(i)
		o.targetY = i - curSelected
		if curSelected == i:
			o.modulate.a = 1
		else:
			o.modulate.a = 0.6
			
	AudioHandler.playSFX("scrollMenu")
	
func spawnOptions():
	for option in options.get_children():
		options.remove_child(option)
		option.queue_free()
		
	var i:int = 0		
	for thing in pauseOptions:
		var newAlphabet = alphabet.duplicate()
		newAlphabet.position.x = (10 * i) + 30
		newAlphabet.position.y = (70 * i) + 30
		options.add_child(newAlphabet)
		
		newAlphabet.label.text = thing
		newAlphabet.label.updateText()
		
		newAlphabet.isMenuItem = true
		newAlphabet.targetY = i
		
		i += 1
		
func tweenTextThingie(label:Label, delay:float = 0.3):
	label.modulate.a = 0
	tween.interpolate_property(label, "modulate:a", 0, 1, 0.4, Tween.TRANS_QUART, Tween.EASE_IN_OUT, delay)
	tween.interpolate_property(label, "rect_position:y", label.rect_position.y, label.rect_position.y + 5, 0.4, Tween.TRANS_QUART, Tween.EASE_IN_OUT, delay)
