extends Node2D

class_name Character

var animFinished:bool = false
var danced:bool = false

var holdTimer = 0

var lastAnim:String = ""

onready var PlayState = $"../"

export(Color) var healthColor = Color("A1A1A1")
export(Texture) var healthIcon = preload("res://assets/images/icons/face.png")
export(String) var animatedHealthIconName = ""
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

func playAnim(animation, force = false):
	var anim:String = animation
	
	if "-alt" in anim and not animPlayer.has_animation(anim):
		anim = anim.split("-alt")[0]
		
	if name != "_" and animPlayer.has_animation(anim):
		animFinished = false
		specialAnim = false
		lastAnim = anim
		
		animPlayer.stop()
		
		if frames:
			frames.stop()
		
		animPlayer.play(anim)
	
func _process(delta):
	if dances:
		if lastAnim != "idle" and !lastAnim.begins_with("dance"):
			holdTimer += delta * PlayStateSettings.songMultiplier
			
			var multiplier:float = 4
			
			if name.to_lower() == "dad":
				multiplier = 6.1
			
			if holdTimer >= Conductor.timeBetweenSteps * singDuration * 0.001:
				if animPlayer.current_animation == "" or animPlayer.current_animation.begins_with("sing") or animPlayer.get_animation(animPlayer.current_animation).loop:
					dance(true)
					holdTimer = 0.0
	
func dance(force = null, alt = null):
	var can = false
	
	if lastAnim.ends_with("-alt") and alt == null:
		alt = true
	
	if dancesLeftRight and lastAnim.begins_with("dance"):
		force = true
	
	if force == null and dancesLeftRight:
		can = animPlayer.current_animation == "" or animPlayer.current_animation.begins_with("dance")
	else:
		can = force or animPlayer.current_animation == ""
	
	if can:
		if dancesLeftRight:
			danced = !danced
			
			if lastAnim.begins_with("singLEFT"):
				danced = true
				
			if lastAnim.begins_with("singRIGHT"):
				danced = false
				
			if danced:
				playAnim("danceLeft", force)
				
				if alt:
					playAnim("danceLeft-alt", force)
			else:
				playAnim("danceRight", force)
				
				if alt:
					playAnim("danceRight-alt", force)
		else:
			playAnim("idle", force)
			
			if alt:
				playAnim("idle-alt", force)
			
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
