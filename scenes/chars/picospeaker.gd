extends Character

var animationNotes:Array = []

func _ready():
	randomize()
	if isPlayer:
		scale.x *= -1
		
	if dances:
		dance(true)
		
	initFrame = frames.frames.get_frame(frames.animation, frames.frame)
	
	var sections:Array = CoolUtil.getJSON(Paths.songJSON("stress", "picospeaker")).song.notes
	for section in sections:
		for note in section.sectionNotes:
			animationNotes.append(note)
			
	#print(TankmenBG.animationNotes)
	#TankmenBG.animationNotes.sort_custom(self, "sortAscending")
	animationNotes.sort_custom(self, "sortAscending")
	
	playAnim('shoot1')
	
func sortAscending(a, b):
	if a[0] < b[0]:
		return true
	return false	

func _physics_process(delta):
	if animationNotes.size() > 0 and Conductor.songPosition > animationNotes[0][0]:
		print("played shoot anim" + str(animationNotes[0][1]))
		var shotDirection:int = 1
		if animationNotes[0][1] >= 2:
			shotDirection = 3
		
		shotDirection += randi()%2
		
		playAnim('shoot' + str(shotDirection), true)
		animationNotes.remove(0)
		
	if animFinished:
		playAnim(lastAnim)
		frames.frame = frames.animation.length() - 3
