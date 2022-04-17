extends Node2D

var bf:Node2D

var death_sound = "fnf_loss_sfx"
var music = "gameOver"
var retry_sound = "gameOverEnd"

var retried = false

var fuck_you = false

var tween = Tween.new()

var funny_timer:Timer

func _ready():
	AudioHandler.stop_inst()
	AudioHandler.stop_voices()
	
	if "-pixel" in Gameplay.death_character:
		death_sound = "fnf_loss_sfx-pixel"
		music = "gameOver-pixel"
		retry_sound = "gameOverEnd-pixel"
	
	$die.stream = load(Paths.sound(death_sound))
	$die.play()

	bf = load("res://Characters/" + Gameplay.death_character + "/char.tscn").instance()
	add_child(bf)
	
	bf.get_node("anim").play("firstDeath")
	
	bf.global_position = Gameplay.death_character_pos
	$Cam.position = Gameplay.death_camera_pos
	
	funny_timer = Timer.new()
	funny_timer.set_wait_time(2.375)
	funny_timer.set_one_shot(true)
	add_child(funny_timer)
	funny_timer.start()
	funny_timer.connect("timeout", self, "start_death_stuff")
	
func _process(delta):
	if bf.get_node("frames").animation == "firstDeath" and bf.get_node("frames").frame == 26:
		$Cam.position = bf.global_position
		$Cam.position.y -= 200
		
	if Input.is_action_just_pressed("ui_back"):
		if Gameplay.story_mode:
			SceneManager.switch_scene("StoryMenu")
		else:
			SceneManager.switch_scene("FreeplayMenu")
		
	if Input.is_action_just_pressed("ui_accept"):
		if not retried:
			funny_timer.stop()
			
			retried = true
			
			$music.stop()
			$music.stream = load(Paths.sound(retry_sound))
			$music.play()
			
			tween = Tween.new()
			tween.interpolate_property(bf, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 4)
			add_child(tween)
			tween.start()
			
			bf.get_node("anim").play("retry")
			
			funny_timer = Timer.new()
			funny_timer.set_wait_time(4)
			funny_timer.set_one_shot(true)
			add_child(funny_timer)
			funny_timer.start()
			funny_timer.connect("timeout", self, "playstate")
		
func playstate():
	SceneManager.switch_scene("PlayState")
		
func start_death_stuff():
	bf.get_node("anim").play("deathLoop")
	
	$music.stream = load(Paths.music(music))
	$music.play()	
