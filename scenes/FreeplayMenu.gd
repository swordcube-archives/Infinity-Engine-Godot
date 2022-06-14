extends Node2D

var songTemplate:FreeplaySong = load("res://scenes/ui/freeplay/SongTemplate.tscn").instance()
onready var songUtil = $SongUtil

var songMakerDifficultyList:Array = []

var songColors:Array = []
var songDifficulties:Array = []

func _ready():
	AudioHandler.playMusic("freakyMenu")
	
	if not OS.is_debug_build():
		$AddNewSong.visible = false
		
	$SongUtil.visible = false
	
	var txt = CoolUtil.getTXT(Paths.txt("data/freeplaySongs"))
	var i:int = 0
	for item in txt:
		var split = item.split(":")
		if len(item) > 0:
			print(split)
			
			var newSong:FreeplaySong = songTemplate.duplicate()
			newSong.position.x = (10 * i) + 30
			newSong.position.y = (70 * i) + 30
			add_child(newSong)
			
			newSong.label.text = split[0]
			newSong.label.updateText()
			
			newSong.isMenuItem = true
			newSong.targetY = i
			
			newSong.icon.texture = load(Paths.healthIcon(split[1]))
			newSong.icon.position.x = newSong.label.label.rect_size.x + 70
			
			i += 1

func _process(delta):
	if not songUtil.visible and Input.is_action_just_pressed("ui_back"):
		Scenes.switchScene("MainMenu")
		AudioHandler.playSFX("cancelMenu")

func _on_AddNewSong_pressed():
	$SongUtil.visible = !$SongUtil.visible

func _on_AddDiff_pressed():
	var d = $SongUtil/DifficultyName.text
	if d != "" and not songMakerDifficultyList.has(d):
		songMakerDifficultyList.append(d)
		
		var dt = $SongUtil/Difficulties
		dt.text = "Difficulties:\n"
		for diff in songMakerDifficultyList:
			dt.text += diff + "\n"
		
func _on_RemoveDiff_pressed():
	var d = $SongUtil/DifficultyName.text
	if d != "" and songMakerDifficultyList.has(d):
		songMakerDifficultyList.erase(d)
		
		var dt = $SongUtil/Difficulties
		dt.text = "Difficulties:\n"
		for diff in songMakerDifficultyList:
			dt.text += diff + "\n"

func _on_ActuallyAddSong_pressed():
	var sn = $SongUtil/SongName.text
	var ci = $SongUtil/CharacterIcon.text
	var bc = $SongUtil/BGColor.text
	
	if sn != "" and ci != "" and songMakerDifficultyList.size() > 0:
		var diffs = ""
		var i:int = 0
		for d in songMakerDifficultyList:
			var comma = ","
			if i == songMakerDifficultyList.size() - 1:
				comma = ""
			diffs += d + comma
			i += 1
			
		var finalData:String = sn + ':' + ci + ':' + bc + ':' + diffs
		print("SAVING FINAL DATA TO res://assets/data/freeplaySongs.txt!!")
		
		var f = File.new()
		var error = f.open(Paths.txt("data/freeplaySongs"), File.READ_WRITE)
		if error == OK:
			f.seek_end()
			f.store_string(finalData)
			f.close()
			
			print("SAVED SUCCESSFULLY.")
		else:
			print("SAVING FAILED.")
