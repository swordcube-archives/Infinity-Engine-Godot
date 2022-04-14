extends "res://Stages/stage.gd"

var trainCooldown: float = 0.0
var trainFrameTiming: float = 0.0
var trainCars: float = 0.0
var time: float = 0.0

var trainMoving = false
var startedMoving = false
var trainFinishing = false

onready var tween = Tween.new()

func _ready():
	add_child(tween)
	
	randomize()
	
	Conductor.connect("beat_hit", self, "beat_hit")

func _process(delta):
	if trainMoving:
		trainFrameTiming += delta

		if trainFrameTiming >= 1.0 / 24.0:
			updateTrainPos()
			trainFrameTiming = 0
			
var lightSelected = -1

func beat_hit():
	if not trainMoving:
		trainCooldown = trainCooldown + 1

	if Conductor.curBeat % 4 == 0:
		lightSelected += 1
		if lightSelected > 4:
			lightSelected = 0

		$city/parallax/windows.texture = load("res://Stages/philly/win" + str(lightSelected) + ".png")
		
		tween.interpolate_property($city/parallax/windows, "modulate", Color(1,1,1,1), Color(1,1,1,0), (Conductor.timeBetweenBeats / 1000) * 4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.stop_all()
		tween.start()

	if Conductor.curBeat % 8 == 4 and rand_range(0, 100) < 20 and not trainMoving and trainCooldown > 8:
		trainCooldown = int(rand_range(-4, 0))
		
		trainMoving = true
		$train_sound.play(0)

func updateTrainPos():
	if $train_sound.get_playback_position() * 1000 >= 4700:
		if "dances" in $"../../Characters".get_node("gf"):
			$"../../Characters".get_node("gf").dances = false
		
		if !startedMoving:
			$"../../Characters".get_node("gf").play_anim("hairBlow", true)
		
		startedMoving = true
		
		if $"../../Characters".get_node("gf").get_node("anim").get_current_animation_position() >= 0.16:
			$"../../Characters".get_node("gf").play_anim("hairBlow", true)

	if startedMoving:
		$train/parallax/spr.position.x -= 400

		if $train/parallax/spr.position.x < -2000 and not trainFinishing:
			$train/parallax/spr.position.x = -1150
			trainCars = trainCars - 1

			if trainCars <= 0:
				trainFinishing = true

		if $train/parallax/spr.position.x < -4000 and trainFinishing:
			trainReset()

func trainReset():
	$"../../Characters".get_node("gf").play_anim("hairFall", true)
	
	$train/parallax/spr.position.x = 2000
	trainMoving = false
	trainCars = 8
	trainFinishing = false
	startedMoving = false
	
	if "dances" in $"../../Characters".get_node("gf"):
		$"../../Characters".get_node("gf").dances = true
