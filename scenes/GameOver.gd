extends Node2D

var bf:Character

func _ready():
	# try to stop the audio 25 times
	# because sometimes it can keep playing for no reason
	for i in 25:
		AudioHandler.inst.stop()
		AudioHandler.voices.stop()
		
	bf = Paths.getCharScene(PlayStateSettings.deathCharacter)
	bf.global_position = PlayStateSettings.deathPosition
	$Camera2D.smoothing_enabled = false
	$Camera2D.position = PlayStateSettings.deathCamPosition
	$Camera2D.zoom = PlayStateSettings.deathCamZoom
	add_child(bf)
	
	bf.playAnim("firstDeath", true)
	yield(get_tree().create_timer(0.1),"timeout")
	$Camera2D.smoothing_enabled = true
	
	$death.stream = bf.deathSound
	$death.play()
	
var accepted:bool = false
	
func _process(delta):			
	if not accepted:
		if bf.lastAnim == "firstDeath" and bf.animPlayer.current_animation_position >= bf.animPlayer.current_animation_length - ((1/24.0) * 15):
			$Camera2D.position = bf.global_position 
			$Camera2D.position.y += ((bf.frames.frames.get_frame(bf.frames.animation, bf.frames.frame).get_height() * bf.frames.scale.y) / 2)
			
		if bf.lastAnim == "firstDeath" and bf.animFinished:
			bf.playAnim("deathLoop", true)
			$music.stream = bf.deathMusic
			$music.play()
		
	if not accepted and Input.is_action_just_pressed("ui_accept"):
		$music.stream = null
		$music.stop()
		
		$retry.stream = bf.retrySound
		$retry.play()
		
		bf.playAnim("retry", true)
		
		accepted = true
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_property(bf, "modulate:a", 1, 0, 4, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()
		yield(get_tree().create_timer(4.45),"timeout")
		Scenes.switchScene("PlayState")
		
	if Input.is_action_just_pressed("ui_back"):
		$music.stop()
		$death.stop()
		$retry.stop()
		if PlayStateSettings.storyMode:
			Scenes.switchScene("StoryMenu")
		else:
			Scenes.switchScene("FreeplayMenu")
		AudioHandler.playMusic("freakyMenu")
