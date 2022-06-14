extends Node2D

onready var rating:Sprite = $rating
onready var comboTemplate:Sprite = $Combo/Template
onready var tween:Tween = $Tween
onready var comboNode:Node2D = $Combo

var combo:String = "000"

func _ready():
	randomize()
	for i in len(combo):
		var comboNum:Sprite = comboTemplate.duplicate()
		comboNum.texture = load("res://assets/images/ui/skins/arrows/combo/num" + combo[i] + ".png")
		comboNum.startVelocity = rand_range(-3, -4)
		comboNum.gravity = rand_range(0.1, 0.15)
		comboNum.position.x += i * 45
		comboNum.moving = true
		comboNum.visible = true
		comboNode.add_child(comboNum)
		
	tweenRating()
	tweenCombo()
	
func _process(delta):
	if comboNode.modulate.a <= 0:
		queue_free()
	
func tweenRating():
	yield(get_tree().create_timer(Conductor.timeBetweenBeats * 0.001), "timeout")
	tween.interpolate_property(rating, "modulate:a", 1, 0, 0.2)
	tween.start()
	
func tweenCombo():
	yield(get_tree().create_timer(Conductor.timeBetweenBeats * 0.002), "timeout")
	tween.interpolate_property(comboNode, "modulate:a", 1, 0, 0.2)
	tween.start()
