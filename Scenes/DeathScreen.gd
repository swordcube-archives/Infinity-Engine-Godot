extends Node2D

onready var camera = $Camera2D

onready var death_sound = $death
onready var death_music = $music

var bf:Node2D

func _ready():
	GameplaySettings.deaths += 1
	
	AudioHandler.inst.stop()
	AudioHandler.voices.stop()
	
	#GameplaySettings.death_shit["character"]
	#GameplaySettings.death_shit["char_pos"]
	#GameplaySettings.death_shit["cam_pos"]
	
	bf = load(Paths.character(GameplaySettings.death_shit["character"])).instance()
	bf.global_position = GameplaySettings.death_shit["char_pos"]
	add_child(bf)
	
	bf.play_anim("firstDeath")
	
	death_sound.stream = bf.death_sound
	death_sound.play()
	
	death_music.stream = bf.death_music
	
	camera.position = GameplaySettings.death_shit["cam_pos"]
	
	yield(get_tree().create_timer(0.1), "timeout")
	camera.position = GameplaySettings.death_shit["char_pos"]
	camera.position.y -= 180
	
var retried:bool = false

onready var tween = $Tween

func _process(delta):
	if Input.is_action_just_pressed("ui_back"):
		SceneHandler.switch_to("FreeplayMenu")
		
	if bf.last_anim == "firstDeath" and bf.anim_finished:
		bf.play_anim("deathLoop")
		death_music.play()
		
	if Input.is_action_just_pressed("ui_accept") and not retried:
		retried = true
		
		bf.play_anim("retry")
		death_music.stop()
		death_sound.stream = bf.retry_sound
		death_sound.play()
		
		tween.interpolate_property(bf, "modulate:a", bf.modulate.a, 0, 4, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()
		
		yield(get_tree().create_timer(4), "timeout")
		SceneHandler.switch_to("PlayState")
		
