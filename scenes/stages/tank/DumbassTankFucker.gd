extends Node2D

onready var frames:AnimatedSprite = $AnimatedSprite

var strumTime:float = 0
var goingRight:bool = false
var tankSpeed:float = 0.7

var endingOffset:float

func _ready():
	frames.play("run")
	
func resetShit(x:float, y:float, goRight:bool):
	position = Vector2(x, y)
	goingRight = goRight
	endingOffset = rand_range(50, 200)
	tankSpeed = rand_range(0.6, 1)
	if goingRight:
		scale.x *= -1
		
var endMeRnPlease:bool = false
var fuckYou:float = 0
		
func _process(delta):
	if frames.animation == "run":
		var wackyShit = (CoolUtil.screenWidth * 0.74) + endingOffset
		
		if goingRight:
			wackyShit = (CoolUtil.screenWidth * 0.02) - endingOffset
			position.x = wackyShit + (Conductor.songPosition - strumTime) * tankSpeed
		else:
			position.x = wackyShit - (Conductor.songPosition - strumTime) * tankSpeed
	else:
		fuckYou += delta
			
	if not endMeRnPlease:
		if Conductor.songPosition > strumTime:
			endMeRnPlease = true
			frames.play('shot' + str(randi()%2+1))
			if goingRight:
				frames.offset.y = -200
				frames.offset.x = -300
	
	if frames.animation.begins_with('shot') and fuckYou >= 1:
		queue_free()
