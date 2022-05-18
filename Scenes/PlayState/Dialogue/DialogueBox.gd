extends Node2D

export(String) var skin = "Default"

var page:int = 0

var json = null

onready var PlayState = $"../../"

onready var bg = $BG
onready var box = $Box

onready var BGTween = $BGTween

func _ready():
	bg.modulate.a = 0
	
func start():
	yield(get_tree().create_timer(0.5), "timeout")
	BGTween.interpolate_property(bg, "modulate:a", 0, 0.2, 1)
	BGTween.start()
	
