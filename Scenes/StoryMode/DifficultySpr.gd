extends Node2D

var tween = Tween.new()
var difficulty = "normal"

func _process(delta):
	if Input.is_action_just_pressed("ui_left"):
		$LeftArrow.play("arrow push left")
		
	if Input.is_action_just_pressed("ui_right"):
		$RightArrow.play("arrow push right")
		
	if Input.is_action_just_released("ui_left"):
		$LeftArrow.play("arrow left")
		
	if Input.is_action_just_released("ui_right"):
		$RightArrow.play("arrow right")

func refresh():
	$DifficultySpr.texture = load("res://Assets/Images/Difficulties/" + difficulty + ".png")
	$DifficultySpr.position.y = $LeftArrow.position.y - 15
	$DifficultySpr.modulate.a = 0

	remove_child(tween)
	tween = Tween.new()
	tween.interpolate_property($DifficultySpr, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.1)
	tween.interpolate_property($DifficultySpr, "position", $DifficultySpr.position, Vector2($DifficultySpr.position.x, $LeftArrow.position.y), 0.1)
	add_child(tween)
	tween.start()
