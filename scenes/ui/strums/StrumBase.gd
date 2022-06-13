extends Node2D

onready var notes:Node2D = $Notes
onready var sustains:ColorRect = $Sustains

onready var spr:AnimatedSprite = $spr

onready var PlayState = $"../../../../"

var isOpponent:bool = false

var oldDirection:String = "A"
export(String) var direction:String = "A"

var dontHit:bool = false

var animFinished:bool = false

func _ready():
	spr.frames = PlayStateSettings.currentUiSkin.strum_tex
	playAnim("static")
	
func _process(delta):
	if oldDirection != direction:
		oldDirection = direction
		playAnim("static")
		
	if PlayStateSettings.downScroll:
		sustains.rect_position.y = -sustains.rect_size.y
	else:
		sustains.rect_position.y = 0
		
	if not isOpponent:
		if Input.is_action_just_pressed("gameplay_" + direction):
			playAnim("press")
			
		if Input.is_action_just_released("gameplay_" + direction):
			playAnim("static")
	else:
		if animFinished:
			playAnim("static")
			
	var scrollSpeed = (PlayStateSettings.scrollSpeed / PlayStateSettings.songMultiplier)
			
	if sustains:
		for note in sustains.get_children():
			note.position.x = (sustains.rect_size.x / 2) - 3
			
			if note.downScroll:
				note.position.y = 0.45 * (Conductor.songPosition - note.strumTime) * scrollSpeed
			else:
				note.position.y = -0.45 * (Conductor.songPosition - note.strumTime) * scrollSpeed
				
			note.position.y -= sustains.rect_position.y
				
			var yourMom = 1 * ((Conductor.timeBetweenSteps / 100 * 1.05) * scrollSpeed)
				
			if not note.isEndOfSustain:
				note.scale.y = yourMom
			else:
				note.spr.centered = false
				note.spr.position.x = -(note.spr.frames.get_frame(note.spr.animation, note.spr.frame).get_width() / 2)
				var among = (scrollSpeed * (Conductor.timeBetweenSteps / 1000.0)) * 230
				if note.downScroll:
					note.position.y += among - 65
				else:
					note.position.y -= among
					
			note.modulate.a = 0.6
				
			if note.mustPress:
				sustains.rect_clip_content = Input.is_action_pressed("gameplay_" + direction)
					
				if Input.is_action_pressed("gameplay_" + direction) and Conductor.songPosition >= note.strumTime + (Conductor.safeZoneOffset / 4):
					PlayState.health += 0.023
					AudioHandler.voices.volume_db = 0
					PlayState.updateHealth()
					playAnim("confirm")
					sustains.remove_child(note)
					note.queue_free()
					
				if Conductor.songPosition >= note.strumTime + Conductor.safeZoneOffset:
					PlayState.health += -0.0475
					AudioHandler.voices.volume_db = -9999
					PlayState.updateHealth()
					PlayState.UI.healthBar.updateText()
					sustains.remove_child(note)
					note.queue_free()
			else:
				if Conductor.songPosition >= note.strumTime + (Conductor.safeZoneOffset / 4):
					playAnim("confirm")
					sustains.remove_child(note)
					note.queue_free()
		
	if notes:
		dontHit = false
		for note in notes.get_children():
			if note.downScroll:
				note.position.y = 0.45 * (Conductor.songPosition - note.strumTime) * scrollSpeed
			else:
				note.position.y = -0.45 * (Conductor.songPosition - note.strumTime) * scrollSpeed
				
			if note.mustPress:
				if not dontHit:
					if Input.is_action_just_pressed("gameplay_" + direction):
						if Conductor.songPosition >= note.strumTime - (Conductor.safeZoneOffset * 1):
							PlayState.health += 0.023
							AudioHandler.voices.volume_db = 0
							PlayState.updateHealth()
							PlayState.UI.healthBar.updateText()
							playAnim("confirm")
							notes.remove_child(note)
							note.queue_free()
						
						dontHit = true
						
				if Conductor.songPosition >= note.strumTime + (Conductor.safeZoneOffset * 1):
					print("MISS!")
					PlayState.health += -0.0475
					PlayState.songMisses += 1
					AudioHandler.voices.volume_db = -9999
					PlayState.updateHealth()
					PlayState.UI.healthBar.updateText()
					notes.remove_child(note)
					note.queue_free()
			else:						
				if Conductor.songPosition >= note.strumTime:
					playAnim("confirm")
					notes.remove_child(note)
					note.queue_free()

func playAnim(anim:String = "static"):
	match anim:
		"press", "pressed":
			spr.stop()
			spr.frame = 0
			spr.play(direction + " press")
			animFinished = false
		"confirm":
			spr.stop()
			spr.frame = 0
			spr.play(direction + " confirm")
			animFinished = false
		_:
			spr.stop()
			spr.frame = 0
			spr.play(direction + " static")
			animFinished = false

func _on_spr_animation_finished():
	animFinished = true
