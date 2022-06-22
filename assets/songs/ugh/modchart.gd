extends Modchart

onready var dad = PlayState.dad

func stepHit():
	match(Conductor.curStep):
		60, 444, 524, 540, 541, 829:
			if dad:
				dad.holdTimer = 0
				dad.playAnim("ugh")
				dad.specialAnim = true
				yield(get_tree().create_timer((Conductor.timeBetweenBeats/1000.0)),"timeout")
				dad.specialAnim = false
				dad.dance(true)
