extends Node2D

var bf:Node2D

var death_sound = "fnf_loss_sfx"
var music = "gameOver"
var retry_sound = "gameOverEnd"

var retried = false

var fuck_you = false

var tween = Tween.new()

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
	
func _process(delta):
	if bf.get_node("frames").animation == "firstDeath" and bf.get_node("frames").frame == 26:
		$Cam.position = bf.global_position
		$Cam.position.y -= 200
		
	if (bf.get_node("frames").animation == "firstDeath" or bf.get_node("frames").animation == "") and bf.get_node("frames").frame >= 57:
		bf.get_node("anim").play("deathLoop")
		
		$music.stream = load(Paths.music(music))
		$music.play()
		
	if Input.is_action_just_pressed("ui_accept"):
		if not retried:
			retried = true
			
			$music.stop()
			$music.stream = load(Paths.sound(retry_sound))
			$music.play()
			
			tween = Tween.new()
			tween.interpolate_property(bf, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 4)
			add_child(tween)
			tween.start()
			
			bf.get_node("anim").play("retry")
			
	yield(tween, "tween_all_completed")
	if not fuck_you:
		tween.stop_all()
		SceneManager.switch_scene("PlayState")
		fuck_you = true
