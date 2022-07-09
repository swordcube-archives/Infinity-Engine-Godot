extends Modchart

func beatHit():
	if Conductor.curBeat % 8 == 7 and PlayState.bf:
		PlayState.bf.holdTimer = 0
		PlayState.bf.playAnim("hey", true)
		PlayState.bf.specialAnim = true
