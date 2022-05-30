extends Stage

var trainCooldown: float = 0.0
var trainFrameTiming: float = 0.0
var trainCars: float = 0.0
var time: float = 0.0

var trainMoving = false
var startedMoving = false
var trainFinishing = false

var die = false

onready var PlayState:Node2D = $"../"

onready var train = $sky/parallax4/spr
onready var train_sound = $train_sound

onready var windows = $sky/parallax2/windows

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

	if Conductor.cur_beat % 4 == 0:
		lightSelected += 1
		if lightSelected > 4:
			lightSelected = 0

		windows.texture = load("res://Assets/Images/Stages/philly/win" + str(lightSelected) + ".png")
		
		tween.interpolate_property(windows, "modulate", Color(1,1,1,1), Color(1,1,1,0), (Conductor.crochet / 1000) * 4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.stop_all()
		tween.start()

	if Conductor.cur_beat % 8 == 4 and rand_range(0, 100) < 20 and not trainMoving and trainCooldown > 8:
		trainCooldown = int(rand_range(-4, 0))
		
		trainMoving = true
		train_sound.play(0)

func updateTrainPos():
	if train_sound.get_playback_position() * 1000 >= 4700:
		if "dances" in PlayState.gf:
			PlayState.gf.dances = false
		
		if !startedMoving:
			PlayState.gf.play_anim("hairBlow", true)
		
		startedMoving = true
		
		if PlayState.gf.anim_player.get_current_animation_position() >= 0.16:
			PlayState.gf.play_anim("hairBlow", true)

	if startedMoving:
		train.position.x -= 400

		if train.position.x < -2000 and not trainFinishing:
			train.position.x = -1150
			trainCars = trainCars - 1

			if trainCars <= 0:
				trainFinishing = true

		if train.position.x < -4000 and trainFinishing:
			trainReset()

func trainReset():
	PlayState.gf.play_anim("hairFall", true)
	PlayState.gf.danced = true
	
	train.position.x = 2000
	trainMoving = false
	trainCars = 8
	trainFinishing = false
	startedMoving = false
	
	if "dances" in PlayState.gf:
		PlayState.gf.dances = true
