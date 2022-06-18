extends Node2D

class_name Stage

onready var PlayState = $"../"

export(float) var defaultCamZoom:float = 0.9

func _ready():
	Conductor.connect("beatHit", self, "beatHit")
	Conductor.connect("stepHit", self, "stepHit")
	create()
	
func create():
	pass
	
func createPost():
	pass

func beatHit():
	pass
	
func stepHit():
	pass
