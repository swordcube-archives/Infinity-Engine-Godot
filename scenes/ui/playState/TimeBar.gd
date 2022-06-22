extends Node2D

class_name TimeBar

var SONG = PlayStateSettings.SONG.song

onready var text:Label = $Text
onready var bar:ProgressBar = $ProgressBar

const whiteBar:StyleBoxFlat = preload("res://scenes/ui/playState/timeBar/TimeBarWhite.tres")
const blackBar:StyleBoxFlat = preload("res://scenes/ui/playState/timeBar/TimeBarBlack.tres")

func _ready():
	bar.min_value = 0
	bar.max_value = AudioHandler.inst.stream.get_length()
	
func _process(delta):
	var curSection:int = int(Conductor.curStep / 16)
	if curSection < 0:
		curSection = 0
	if curSection > SONG.notes.size() - 1:
		curSection = SONG.notes.size() - 1
		
	if SONG.notes[curSection].mustHitSection:
		whiteBar.bg_color = HealthBar.greenHealth.bg_color
	else:
		whiteBar.bg_color = HealthBar.redHealth.bg_color
		
	text.text = CoolUtil.formatTime(AudioHandler.inst.get_playback_position()) + " / " + CoolUtil.formatTime(AudioHandler.inst.stream.get_length())
	bar.value = AudioHandler.inst.get_playback_position()
