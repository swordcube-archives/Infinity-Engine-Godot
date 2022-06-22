extends Modchart

onready var bf:Node2D = PlayState.bf

func beatHit():
	if Conductor.curBeat % 8 == 7 and bf:
		bf.holdTimer = 0
		bf.playAnim("hey", true)
		bf.specialAnim = true
