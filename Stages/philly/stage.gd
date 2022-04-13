extends Node2D

var cur_window = -1
var window_nums = [0, 1, 2, 3, 4]

var train_moving = false

var trainCars = 8
var trainFinishing = false
var trainCooldown = 0
var trainFrameTiming = 0.0

var fuck = 0.0

var og_train_pos

export(float) var default_cam_zoom = 1

func _ready():
	og_train_pos = $train/parallax/spr.global_position
	
	Conductor.connect("beat_hit", self, "beat_hit")
	#Conductor.connect("step_hit", self, "step_hit")

func beat_hit():
	randomize()
	
	if not $"../../".countdown_active:
		trainCooldown += 1
		
		if Conductor.curBeat % 4 == 0:
			cur_window += 1
			
			if cur_window > len(window_nums) - 1:
				cur_window = 0
				
			$city/parallax/windows.texture = load("res://Stages/philly/win" + str(window_nums[cur_window]) + ".png")
			
		if Conductor.curBeat % 8 == 4 and randi()%30 + 1 == 10 and not train_moving and trainCooldown > 8:		
			trainCooldown = int(rand_range(-4, 0))
			train_start()
			
func train_start():
	train_moving = true
	if not $train_sound.playing:
		$train_sound.play()
				
func train_reset():
	train_moving = false
	trainCars = 8
	trainFinishing = false
	$train/parallax/spr.global_position.x = 3600
				
func _process(delta):
	if train_moving:		
		if ($train_sound.get_playback_position() * 1000) >= 4700:
			trainFrameTiming += delta
			fuck += delta
			
			if fuck >= 1.0 / 10.0:
				$"../../Characters/gf".play_anim("hairLand")
				$"../../Characters/gf".danced = true
				fuck = 0

			if trainFrameTiming >= 1.0 / 24.0:
				$train/parallax/spr.global_position.x -= 400
				trainFrameTiming = 0
		else:
			$train/parallax/spr.global_position.x = 3600
			trainFrameTiming = 0
			fuck = 0

		if not trainFinishing and $train/parallax/spr.global_position.x < -500:
			$train/parallax/spr.global_position.x = 2500
			
			trainCars -= 1
			if trainCars <= 0:
				trainFinishing = true
			
		if trainFinishing and $train/parallax/spr.global_position.x < -2000:
			train_reset()
