extends Node2D

class_name Character

var animFinished:bool = false
var danced:bool = false

var holdTimer = 0

var lastAnim:String = ""

onready var PlayState = $"../"

export(Color) var healthColor = Color("A1A1A1")
export(Texture) var healthIcon = preload("res://assets/images/icons/face.png")
export(bool) var dancesLeftRight = false
export(float) var singDuration = 4
export(String) var deathCharacter = "bf-dead"
export(bool) var isPlayer = false
export(bool) var dances = true
export(AudioStream) var deathSound = preload("res://assets/sounds/fnf_loss_sfx.ogg")
export(AudioStream) var deathMusic = preload("res://assets/music/gameOver.ogg")
export(AudioStream) var retrySound = preload("res://assets/sounds/gameOverEnd.ogg")

var initFrame 

var specialAnim = false

onready var animPlayer:AnimationPlayer = $AnimationPlayer
onready var frames:AnimatedSprite = $AnimatedSprite

export(Vector2) var camera_pos:Vector2 = Vector2(0, 0)

func _ready():
	if isPlayer:
		scale.x *= -1
		
	if dances:
		dance(true)
		
	initFrame = frames.frames.get_frame(frames.animation, frames.frame)

func playAnim(anim, force = false):
	if (name != "_" or force) and animPlayer.get_animation(anim) != null:
		animFinished = false
		specialAnim = false
		lastAnim = anim
		
		animPlayer.stop()
		
		if frames:
			frames.stop()
		
		animPlayer.play(anim)
	
func _process(delta):
	if dances:
		if not isPlayer:
			if lastAnim.begins_with('sing'):
				holdTimer += delta * PlayStateSettings.songMultiplier
				
				if holdTimer >= Conductor.timeBetweenSteps * singDuration * 0.001:
					dance(true)
					holdTimer = 0.0
		else:
			if lastAnim.begins_with('sing'):
				holdTimer += delta * PlayStateSettings.songMultiplier
				
				if holdTimer > Conductor.timeBetweenSteps * singDuration * 0.001 and not PlayState.pressed.has(true):
					if lastAnim.begins_with('sing') and not lastAnim.ends_with('miss'):
						dance()
			else:
				holdTimer = 0
	
func dance(force = null):
	if force == null:
		force = dancesLeftRight
	
	if force or animPlayer.current_animation == "":
		if dancesLeftRight:
			danced = not danced
			
			if lastAnim.begins_with("singLEFT"):
				danced = true
				
			if lastAnim.begins_with("singRIGHT"):
				danced = false
				
			if danced:
				playAnim("danceLeft", force)
			else:
				playAnim("danceRight", force)
		else:
			playAnim("idle", force)
			
func isDancing():
	var dancing = true
		
	if !lastAnim.begins_with("idle") and !lastAnim.begins_with("dance"):
		dancing = false
	
	return dancing
	
func getMidpoint():
	return Vector2(global_position.x + ((initFrame.get_width() * frames.scale.x) * 0.5), global_position.y + ((initFrame.get_height() * frames.scale.y) * 0.5))

func _on_AnimationPlayer_animation_finished(anim_name):
	animFinished = true
	
	if animPlayer.has_animation(lastAnim + "-loop"):
		playAnim(lastAnim + "-loop")
