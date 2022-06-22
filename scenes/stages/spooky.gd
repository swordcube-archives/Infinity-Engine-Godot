extends Stage

onready var bg = $AnimatedSprite

var lightningStrikeBeat:int = 0
var lightningOffset:int = 8

func beatHit():
	if rand_range(0, 100) < 10 and Conductor.curBeat > lightningStrikeBeat + lightningOffset:
		lightningStrikeShit(Conductor.curBeat)
		
func lightningStrikeShit(curBeat):
	var rand = randi()%2+1
	get_node("strike" + str(rand)).play()

	bg.play("strike")

	lightningStrikeBeat = curBeat
	lightningOffset = int(rand_range(8, 24))

	PlayState.gf.playAnim('scared', true)
	PlayState.bf.playAnim('scared', true)
