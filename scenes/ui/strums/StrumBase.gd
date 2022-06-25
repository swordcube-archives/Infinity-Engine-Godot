extends Node2D

onready var notes:Node2D = $Notes
onready var sustains:ColorRect = $Sustains

onready var spr:AnimatedSprite = $spr

onready var PlayState = $"../../../../"

var isOpponent:bool = false

var oldDirection:String = "A"
export(String) var direction:String = "A"

var dontHit:bool = false

var animFinished:bool = false

var characterAnimTimer:float = 0.0

func _ready():
	spr.frames = PlayStateSettings.currentUiSkin.strum_tex
	var ss = PlayStateSettings.currentUiSkin.strum_scale
	spr.scale = Vector2(ss, ss)
	playAnim("static")
	
func sortNotes(a, b):
	if a.strumTime < b.strumTime:
		return true
		
	return false
	
func _process(delta):
	if oldDirection != direction:
		oldDirection = direction
		playAnim("static")
		
	if PlayStateSettings.downScroll:
		sustains.rect_position.y = -sustains.rect_size.y
	else:
		sustains.rect_position.y = 0
		
	if not isOpponent:
		if not PlayStateSettings.botPlay and Input.is_action_just_pressed("gameplay_" + direction):
			PlayState.pressed[0] = true
			playAnim("press")
			
		if (not PlayStateSettings.botPlay and Input.is_action_just_released("gameplay_" + direction)) or (PlayStateSettings.botPlay and animFinished):
			PlayState.pressed[0] = false
			playAnim("static")
	else:
		if animFinished:
			playAnim("static")

	var scrollSpeed = PlayStateSettings.scrollSpeed

	if notes:
		dontHit = false
		var possibleNotes:Array = []
		for note in notes.get_children():
			if Conductor.songPosition >= note.strumTime - Conductor.safeZoneOffset:
				possibleNotes.append(note)
				
		possibleNotes.sort_custom(self, "sortNotes")
				
		for note in notes.get_children():
			if (not note.mustPress and Conductor.songPosition >= note.strumTime) or (note.beingPressed and Input.is_action_pressed("gameplay_" + direction)) or (PlayStateSettings.botPlay and Conductor.songPosition >= note.strumTime):
				note.spr.visible = false
				note.position.y = 0
				
				if not note.mustPress:
					characterAnimTimer += delta
					if characterAnimTimer >= Conductor.timeBetweenSteps/1000.0:
						opponentSing(note)
				else:
					characterAnimTimer += delta
					if characterAnimTimer >= Conductor.timeBetweenSteps/1000.0:
						playerSing(note)
				
				if (not note.mustPress and Conductor.songPosition >= note.strumTime) or (note.mustPress and Conductor.songPosition >= note.strumTime and (Input.is_action_pressed("gameplay_" + direction))) or PlayStateSettings.botPlay:
					note.sustainLength -= (delta * 1000.0) * PlayStateSettings.songMultiplier
						
					if note.sustainLength <= -20:
						notes.remove_child(note)
						note.queue_free()
			else:
				if note.downScroll:
					note.position.y = 0.45 * (Conductor.songPosition - note.strumTime) * scrollSpeed
				else:
					note.position.y = -0.45 * (Conductor.songPosition - note.strumTime) * scrollSpeed
				
		for note in possibleNotes:
			if note.mustPress:
				if not dontHit:
					if Input.is_action_just_pressed("gameplay_" + direction) or PlayStateSettings.botPlay:
						if not note.beingPressed and ((PlayStateSettings.botPlay and Conductor.songPosition >= note.strumTime) or not PlayStateSettings.botPlay):
							note.beingPressed = true
							
							playerSing(note)
							
							PlayState.combo += 1
							PlayState.totalNotes += 1
							
							var rating:String = Ranking.judgeNote(note.strumTime)
							if PlayStateSettings.botPlay:
								rating = "marvelous"
							
							var newRating:Node2D = PlayState.UI.ratingTemplate.duplicate()
							newRating.position = Vector2(685, 230)
							newRating.combo = CoolUtil.numToComboStr(PlayState.combo)
							PlayState.UI.add_child(newRating)
								
							var texture:StreamTexture
							match rating:
								"marvelous":
									PlayState.marv += 1
									texture = PlayStateSettings.currentUiSkin.marvelous_tex
								"sick":
									PlayState.sicks += 1
									texture = PlayStateSettings.currentUiSkin.sick_tex
								"good":
									PlayState.goods += 1
									texture = PlayStateSettings.currentUiSkin.good_tex
								"bad":
									PlayState.bads += 1
									texture = PlayStateSettings.currentUiSkin.bad_tex
								"shit":
									PlayState.shits += 1
									texture = PlayStateSettings.currentUiSkin.shit_tex
									
							var rankingShit = Ranking.judgements[rating]
							if not PlayStateSettings.botPlay:
								PlayState.songScore += rankingShit["score"]
							PlayState.totalHit += rankingShit["mod"]
							if rankingShit.has("health"):
								PlayState.health += rankingShit["health"]
								
							newRating.rating.texture = texture
								
							if Preferences.getOption("note-splashes") and rankingShit.has("noteSplash"):
								var strum = PlayState.UI.playerStrums.get_child(note.noteData)
								if Preferences.getOption("play-as-opponent"):
									strum = PlayState.UI.opponentStrums.get_child(note.noteData)
									
								var noteSplash:Node2D = load("res://scenes/ui/playState/NoteSplash.tscn").instance()
								noteSplash.direction = strum.direction
								noteSplash.position = strum.global_position
								PlayState.UI.add_child(noteSplash)
							
							if Preferences.getOption("hitsound") != "None":
								var newHitsound = PlayState.hitsound.duplicate()
								newHitsound.isClone = true
								newHitsound.play()
								PlayState.add_child(newHitsound)
							
							AudioHandler.voices.volume_db = 0
							PlayState.updateHealth()
							PlayState.UI.healthBar.updateText()
							if note.ogSustainLength <= 0:
								notes.remove_child(note)
								note.queue_free()
							
							# remove stacked notes
							for coolNote in notes.get_children():
								if coolNote.ogSustainLength <= 0:
									if ((coolNote.strumTime - note.strumTime) < 2) and coolNote.noteData == note.noteData:
										notes.remove_child(coolNote)
										note.queue_free()
						
						dontHit = true
						
						# missing
		
				# you can no longer just hold down the keys to hit sustains
				# you have to actually try to hit them now :D
				
				# edit this to edit how early you can release without
				# getting punished
				var sustainMissRange = 100
				
				var your = (note.mustPress and note.ogSustainLength <= 0 and not PlayStateSettings.botPlay)
				var your2 = (note.mustPress and note.ogSustainLength >= 0 and not Input.is_action_pressed("gameplay_" + direction) and not PlayStateSettings.botPlay)
						
				if (not Input.is_action_pressed("gameplay_" + direction) and note.beingPressed and note.sustainLength <= sustainMissRange) and not PlayStateSettings.botPlay:
					note.sustainLength -= (delta * 1000) * PlayStateSettings.songMultiplier
					note.spr.visible = false
					note.position.y = 0
					
					if note.sustainLength <= -20:
						note.queue_free()
				elif your or your2 or (note.mustPress and not note.beingPressed and Input.is_action_pressed("gameplay_" + direction)):
					if Conductor.songPosition >= note.strumTime + Conductor.safeZoneOffset:
						var characterSinging = PlayState.bf
						if Preferences.getOption("play-as-opponent"):
							characterSinging = PlayState.dad
							
						if characterSinging and not characterSinging.specialAnim:
							var altAnim = ""
							if note.altNote:
								altAnim = "-alt"
								
							characterSinging.holdTimer = 0
							characterSinging.playAnim(CoolUtil.singAnims[PlayState.SONG["keyCount"]][note.noteData] + "miss" + altAnim)
						
						var loss:float = -0.0475
						loss *= Preferences.getOption("hp-loss-multiplier")
						PlayState.health += loss
						PlayState.songMisses += 1
						if PlayState.combo >= 10:
							if PlayState.gf:
								PlayState.gf.playAnim('sad')
						PlayState.combo = 0
						PlayState.totalNotes += 1
						AudioHandler.voices.volume_db = -9999
						PlayState.updateHealth()
						PlayState.UI.healthBar.updateText()
						notes.remove_child(note)
						note.queue_free()
			else:						
				if not note.beingPressed and Conductor.songPosition >= note.strumTime:
					note.beingPressed = true
					
					opponentSing(note)
					
func opponentSing(note):
	var characterSinging = PlayState.dad
	if Preferences.getOption("play-as-opponent"):
		characterSinging = PlayState.bf
		
	var health:float = PlayState.health
	health -= 1 * Preferences.getOption("health-drain")
	if health < 0.023:
		health = 0.023
		
	PlayState.health = health
		
	if characterSinging and not characterSinging.specialAnim:
		var altAnim = ""
		if note.altNote:
			altAnim = "-alt"
			
		characterSinging.holdTimer = 0
		characterSinging.playAnim(CoolUtil.singAnims[PlayState.SONG["keyCount"]][note.noteData] + altAnim)
	
	characterAnimTimer = 0.0
	playAnim("confirm")
	AudioHandler.voices.volume_db = 0
	if note.ogSustainLength <= 0:
		notes.remove_child(note)
		note.queue_free()
		
func playerSing(note):
	var characterSinging = PlayState.bf
	if Preferences.getOption("play-as-opponent"):
		characterSinging = PlayState.dad
		
	if characterSinging and not characterSinging.specialAnim:
		var altAnim = ""
		if note.altNote:
			altAnim = "-alt"
		characterSinging.holdTimer = 0
		characterSinging.playAnim(CoolUtil.singAnims[PlayState.SONG["keyCount"]][note.noteData] + altAnim)

		characterAnimTimer = 0.0
		playAnim("confirm")
		
		var gain:float = 0.023
		gain *= Preferences.getOption("hp-gain-multiplier")
		PlayState.health += gain

func playAnim(anim:String = "static"):
	match anim:
		"press", "pressed":
			spr.stop()
			spr.frame = 0
			spr.play(direction + " press")
			animFinished = false
		"confirm":
			spr.stop()
			spr.frame = 0
			spr.play(direction + " confirm")
			animFinished = false
		_:
			spr.stop()
			spr.frame = 0
			spr.play(direction + " static")
			animFinished = false

func _on_spr_animation_finished():
	animFinished = true
