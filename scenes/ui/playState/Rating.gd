extends Node2D

onready var rating:Sprite = $rating
onready var comboTemplate:Sprite = $Combo/Template
onready var tween:Tween = $Tween
onready var comboNode:Node2D = $Combo

var combo:String = "000"

func _ready():
	randomize()
	
	var rs = PlayStateSettings.currentUiSkin.rating_scale
	rating.scale = Vector2(rs, rs)
	
	rating.acceleration.y = 550
	rating.velocity.y -= floor(rand_range(140, 175))
	rating.velocity.x -= floor(rand_range(0, 10))
	
	for i in len(combo):
		var comboNum:Sprite = comboTemplate.duplicate()
		comboNum.texture = PlayStateSettings.currentUiSkin.get("combo_" + combo[i])
		
		comboNum.position.x += i * 45
		
		comboNum.acceleration.y = floor(rand_range(200, 300))
		comboNum.velocity.y -= floor(rand_range(140, 160))
		comboNum.velocity.x = rand_range(-5, 5)
		
		comboNum.moving = true
		comboNum.visible = true
		comboNode.add_child(comboNum)
		
		var cs = PlayStateSettings.currentUiSkin.combo_scale
		comboNum.scale = Vector2(cs, cs)
		
	tweenRating()
	tweenCombo()
	
func _process(delta):
	if comboNode.modulate.a <= 0:
		queue_free()
	
func tweenRating():
	tween.interpolate_property(rating, "modulate:a", 1, 0, 0.2, 0, 2, Conductor.timeBetweenBeats * 0.001)
	tween.start()
	
func tweenCombo():
	tween.interpolate_property(comboNode, "modulate:a", 1, 0, 0.2, 0, 2, Conductor.timeBetweenBeats * 0.002)
	tween.start()
