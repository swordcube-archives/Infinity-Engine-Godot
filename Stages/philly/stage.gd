extends Node2D

var cur_window = -1
var window_nums = [0, 1, 2, 3, 4]

var train_moving = false

var trainCars = 8
var trainFinishing = false
var trainCooldown = 0
var trainFrameTiming = 0

var og_train_pos

export(float) var default_cam_zoom = 1

func _ready():
	og_train_pos = $train/parallax/spr.global_position
	
	Conductor.connect("beat_hit", self, "beat_hit")
	#Conductor.connect("step_hit", self, "step_hit")

func beat_hit():
	if not get_node("../../").countdown_active:
		trainCooldown += 1
		
		if Conductor.curBeat % 4 == 0:
			cur_window += 1
			
			if cur_window > len(window_nums) - 1:
				cur_window = 0
				
			$city/parallax/windows.texture = load("res://Stages/philly/win" + str(window_nums[cur_window]) + ".png")
			
		if Conductor.curBeat % 8 == 4 and randi()%30 + 1 == 10 and not train_moving and trainCooldown > 8:		
			trainCooldown = int(rand_range(-4, 0))
			train_moving = true
				
func train_reset():
	train_moving = false
	trainCars = 8
	trainFinishing = false
	$train/parallax/spr.global_position.x = og_train_pos.x
				
func _process(delta):
	if train_moving:
		trainFrameTiming += delta

		if trainFrameTiming >= 1 / 24:
			$train/parallax/spr.global_position.x -= 400
			trainFrameTiming = 0

		if not trainFinishing and $train/parallax/spr.global_position.x < -500:
			$train/parallax/spr.global_position.x = 2500
			
			trainCars -= 1
			if trainCars <= 0:
				trainFinishing = true
			
		if trainFinishing and $train/parallax/spr.global_position.x < -2000:
			train_reset()
