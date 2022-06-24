extends Modchart

onready var dad = PlayState.dad

func stepHit():
	if dad:
		match Conductor.curStep:
			736:
				dad.dances = false
				dad.frames.speed_scale = PlayStateSettings.songMultiplier
				dad.playAnim("prettyGood", true)
				dad.holdTimer = 0
				
				# because normally you would hit a note for the
				# "hey! pretty good!" shit to activate
				if Preferences.getOption("play-as-opponent"):
					PlayState.songScore += 350
			768:
				dad.dances = true
				dad.frames.speed_scale = 1.0
				dad.holdTimer = 0
