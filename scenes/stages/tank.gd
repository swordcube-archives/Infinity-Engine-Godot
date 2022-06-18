extends Stage

onready var tankRolling:AnimatedSprite = $ParallaxBackground/layer7/TankRolling

var tankAngle:float = rand_range(-90, 45)
var tankSpeed:float = rand_range(5, 7)
var tankX:float = 400

func createPost():
	randomize()
	
	if PlayState.SONG.song.to_lower() == "stress":
		var tankmen = preload("res://scenes/stages/tank/TankFucker.tscn").instance()
		tankmen.strumTime = 10
		tankmen.resetShit(20, 300, true)
		$TankmenRun.add_child(tankmen)
		for i in PlayState.gf.animationNotes.size() - 1:
			if rand_range(0, 85) < 16:
				var man = preload("res://scenes/stages/tank/TankFucker.tscn").instance()
				man.strumTime = PlayState.gf.animationNotes[i][0]
				man.resetShit(500, 200 + int(rand_range(50, 100)), PlayState.gf.animationNotes[i][1] < 2)
				$TankmenRun.add_child(man)

func _process(delta):
	moveTank(delta)
	
func moveTank(delta):
	tankAngle += tankSpeed * delta
	tankRolling.rotation_degrees = (tankAngle - 90 + 15)
	tankRolling.position.x = 400 + 1500 * cos(PI / 180 * (1 * tankAngle + 180))
	tankRolling.position.y = 1300 + 1100 * sin(PI / 180 * (1 * tankAngle + 180))
