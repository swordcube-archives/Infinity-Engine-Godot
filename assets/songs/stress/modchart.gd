extends Modchart

onready var dad = PlayState.dad

func stepHit():
	if dad:
		match Conductor.curStep:
			736:
				dad.dances = false
				dad.holdTimer = 0
				dad.playAnim("prettyGood")
				dad.specialAnim = true
				yield(get_tree().create_timer((Conductor.timeBetweenBeats/1000.0)*2.5),"timeout")
				dad.specialAnim = false
			768:
				dad.dances = true
				dad.holdTimer = 0
