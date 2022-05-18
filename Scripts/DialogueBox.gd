extends Node2D

onready var frames = $frames
onready var anim_player = $anim

func play_anim(state:String = "normal", anim:String = "idle"):
	frames.stop()
	anim_player.play(state + " " + anim)
