extends Modchart

func beatHit():
	if Conductor.curBeat > 16 and Conductor.curBeat < 48:
		if Conductor.curBeat % 16 == 15 and PlayState.bf:
			PlayState.bf.holdTimer = 0
			PlayState.bf.playAnim("hey", true)
			
			if PlayState.SONG.player2 == PlayState.gfVersion:
				PlayState.dad.holdTimer = 0
				PlayState.dad.playAnim("cheer", true)
			else:
				PlayState.gf.holdTimer = 0
				PlayState.gf.playAnim("cheer", true)
