extends Stage

var phillyLightsColors = [
	0xFF31a2fd, # blue
	0xFF31fd8c, # green
	0xFFfb33f5, # pink
	0xFFfd4531, # red
	0xFFfba633 # orange
]

var trainCooldown:float = 0.0
var trainFrameTiming:float = 0.0
var trainCars:float = 0.0
var time:float = 0.0

var trainMoving = false
var startedMoving = false
var trainFinishing = false

onready var train = $Train
onready var train_spr = $TrainSpr

func _physics_process(delta):
	if trainMoving:
		trainFrameTiming += delta

		if trainFrameTiming >= 1.0 / 24.0:
			updateTrainPos()
			trainFrameTiming = 0.0

onready var windows:Sprite = $ParallaxBackground/layer2/WinWhite

var tween = Tween.new()

func create():
	randomize()
	add_child(tween)
	
func updateTrainPos():
	if train.get_playback_position() * 1000 >= 4700:
		if "dances" in PlayState.gf:
			PlayState.gf.dances = false
		
		if !startedMoving:
			PlayState.gf.playAnim("hairBlow", true)
		
		startedMoving = true
		
		if PlayState.gf.animPlayer.get_current_animation_position() >= 0.16:
			PlayState.gf.playAnim("hairBlow", true)

	if startedMoving:
		train_spr.position.x = train_spr.position.x - 400
		
		if train_spr.position.x < -2000 and not trainFinishing:
			train_spr.position.x = -1150
			trainCars = trainCars - 1
			
			if trainCars <= 0:
				trainFinishing = true
		
		if train_spr.position.x < -4000 and trainFinishing:
			trainReset()
			
func trainReset():
	PlayState.gf.playAnim("hairFall", true)
	
	train_spr.position.x = 2000
	trainMoving = false
	trainCars = 8
	trainFinishing = false
	startedMoving = false
	
	PlayState.gf.danced = true
	
	if "dances" in PlayState.gf:
		PlayState.gf.dances = true

func beatHit():
	if Conductor.curBeat % 4 == 0:
		windows.texture = load("res://assets/images/stages/philly/win" + str(randi()%5) + ".png")
		windows.modulate.a = 1
		tween.stop_all()
		tween.interpolate_property(windows, "modulate:a", 1, 0, (Conductor.timeBetweenBeats / 1000.0) * 4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		
	if not trainMoving:
		trainCooldown += 1
		
	if Conductor.curBeat % 8 == 4 and rand_range(0, 100) < 20 and not trainMoving and trainCooldown > 8:
		trainCooldown = int(rand_range(-4, 0))
		
		trainMoving = true
		train.play(0)
