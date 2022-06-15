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
	
	for i in len(combo):
		var comboNum:Sprite = comboTemplate.duplicate()
		comboNum.texture = PlayStateSettings.currentUiSkin.get("combo_" + combo[i])
		comboNum.startVelocity = rand_range(-3, -4)
		comboNum.gravity = rand_range(0.1, 0.15)
		comboNum.position.x += i * 45
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
	yield(get_tree().create_timer(Conductor.timeBetweenBeats * 0.001), "timeout")
	tween.interpolate_property(rating, "modulate:a", 1, 0, 0.2)
	tween.start()
	
func tweenCombo():
	yield(get_tree().create_timer(Conductor.timeBetweenBeats * 0.002), "timeout")
	tween.interpolate_property(comboNode, "modulate:a", 1, 0, 0.2)
	tween.start()
