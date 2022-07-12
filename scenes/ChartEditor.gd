extends Node2D

var characterList:Array = []
var stageList:Array = []
var uiSkinList:Array = []

var curSection:int = 0

var SONG = PlayStateSettings.SONG.song

var playing:bool = false

onready var camera = $Camera2D

onready var dropdowns:Dictionary = {
	"opponent": $CanvasLayer/TabContainer/Art/Opponent/OptionButton,
	"girlfriend": $CanvasLayer/TabContainer/Art/GF/OptionButton,
	"player": $CanvasLayer/TabContainer/Art/Player/OptionButton,
	"stage": $CanvasLayer/TabContainer/Art/Stage/OptionButton,
	"ui-skin": $CanvasLayer/TabContainer/Art/UISkin/OptionButton,
}

onready var lineedits:Dictionary = {
	"song": $CanvasLayer/TabContainer/Song/Song/LineEdit,
	"bpm": $CanvasLayer/TabContainer/Song/BPM/NumericStepper,
	"scroll-speed": $CanvasLayer/TabContainer/Song/ScrollSpeed/NumericStepper,
	"difficulty": $CanvasLayer/TabContainer/Song/Difficulty/LineEdit,
}

onready var icons:Dictionary = {
	"p2": $CanvasLayer/iconP2,
	"p1": $CanvasLayer/iconP1,
}

onready var grids:Array = [
	$bgGrid,
	$Grid,
	$fgGrid,
]

func _input(event:InputEvent):
	if Input.is_action_just_pressed("ui_space"):
		playing = !playing
		if playing:
			AudioHandler.playInst(SONG.song)
			AudioHandler.playVoices(SONG.song)
			
			AudioHandler.inst.seek(Conductor.songPosition / 1000.0)
			AudioHandler.voices.seek(Conductor.songPosition / 1000.0)
		else:
			AudioHandler.stopMusic()
		
	if Input.is_action_just_pressed("ui_confirm"):
		playing = false
		Scenes.switchScene("PlayState")
		AudioHandler.stopMusic()
	
	if event is InputEventMouseButton:
		event as InputEventMouseButton
		if event.pressed:
			match event.button_index:
				BUTTON_WHEEL_UP:
					print("UP")
					if Input.is_action_pressed("ui_shift"):
						Conductor.songPosition -= 100
					else:
						Conductor.songPosition -= 25
					
					if Conductor.songPosition < 0:
						Conductor.songPosition = 0
					
					if Conductor.songPosition < grids[1].section_start_time():
						curSection -= 1
						
						if curSection < 0:
							curSection = 0
							
						grids[0].curSection = curSection-1
						grids[1].curSection = curSection
						grids[2].curSection = curSection+1
						
						grids[0].loadSection()
						grids[1].loadSection()
						grids[2].loadSection()
				BUTTON_WHEEL_DOWN:
					print("DOWN")
					if Input.is_action_pressed("ui_shift"):
						Conductor.songPosition += 100
					else:
						Conductor.songPosition += 25
					
					if Conductor.songPosition > grids[1].section_start_time() + (4 * (1000 * (60 / Conductor.bpm))):
						curSection += 1
						
						grids[0].curSection = curSection-1
						grids[0].loadSection()
						grids[1].curSection = curSection
						grids[1].loadSection()
						grids[2].curSection = curSection+1
						grids[2].loadSection()

func _ready():
	Conductor.changeBPM(SONG.bpm, Conductor.mapBPMChanges(SONG))
	PlayStateSettings.makeSongSettingsReal()
	
	AudioHandler.stopMusic()
	
	characterList.append("")
	dropdowns["opponent"].add_item("")
	dropdowns["girlfriend"].add_item("")
	dropdowns["player"].add_item("")
	
	for file in CoolUtil.listFilesInDirectory("res://scenes/chars/"):
		if file.ends_with(".tscn"):
			characterList.append(file.split(".tscn")[0])
			dropdowns["opponent"].add_item(file.split(".tscn")[0])
			dropdowns["girlfriend"].add_item(file.split(".tscn")[0])
			dropdowns["player"].add_item(file.split(".tscn")[0])
			
	for file in CoolUtil.listFilesInDirectory("res://scenes/stages/"):
		if file.ends_with(".tscn"):
			stageList.append(file.split(".tscn")[0])
			dropdowns["stage"].add_item(file.split(".tscn")[0])
			
	uiSkinList.append("")
	dropdowns["ui-skin"].add_item("")
	for item in CoolUtil.listFilesInDirectory("res://assets/images/ui/skins/"):
		if not "." in item:
			for file in CoolUtil.listFilesInDirectory("res://assets/images/ui/skins/"+item):
				if file.ends_with(".tscn"):
					uiSkinList.append(item)
					dropdowns["ui-skin"].add_item(item)
			
	dropdowns["opponent"].text = SONG.player2
	dropdowns["opponent"].select(characterList.find(SONG.player2))
	
	dropdowns["girlfriend"].text = SONG.gf
	dropdowns["girlfriend"].select(characterList.find(SONG.gf))
	
	dropdowns["player"].text = SONG.player1
	dropdowns["player"].select(characterList.find(SONG.player1))
	
	dropdowns["stage"].text = SONG.stage
	dropdowns["stage"].select(stageList.find(SONG.stage))
	
	dropdowns["ui-skin"].text = SONG.uiSkin
	dropdowns["ui-skin"].select(uiSkinList.find(SONG.uiSkin))
	
	lineedits["song"].text = SONG.song
	lineedits["bpm"].value = float(SONG.bpm)
	lineedits["scroll-speed"].value = float(SONG.speed)
	lineedits["difficulty"].text = PlayStateSettings.difficulty
	
	$CanvasLayer/TabContainer/Art/IsPixelStage.pressed = SONG.pixelStage
	grids[0].curSection = curSection-1
	grids[0].loadSection()
	grids[1].curSection = curSection
	grids[1].loadSection()
	grids[2].curSection = curSection+1
	grids[2].loadSection()
	
func _physics_process(_delta):
	var inst_pos = (AudioHandler.inst.get_playback_position() * 1000) + (AudioServer.get_time_since_last_mix() * 1000)
	inst_pos -= AudioServer.get_output_latency() * 1000
	
	if playing and inst_pos > Conductor.songPosition - (AudioServer.get_output_latency() * 1000) + 30 or inst_pos < Conductor.songPosition - (AudioServer.get_output_latency() * 1000) - 30:
		AudioHandler.inst.seek(Conductor.songPosition / 1000)
		AudioHandler.voices.seek(Conductor.songPosition / 1000)
	
func _process(delta):
	if SONG.notes[curSection].mustHitSection:
		icons["p2"].texture = load(Paths.healthIcon(SONG.player1))
		icons["p1"].texture = load(Paths.healthIcon(SONG.player2))
	else:
		icons["p2"].texture = load(Paths.healthIcon(SONG.player2))
		icons["p1"].texture = load(Paths.healthIcon(SONG.player1))
		
	if playing:
		Conductor.songPosition += delta * 1000.0
		
		if Conductor.songPosition >= grids[1].section_start_time() + (4 * (1000 * (60 / Conductor.bpm))):
			curSection += 1
			grids[0].curSection = curSection-1
			grids[0].loadSection()
			grids[1].curSection = curSection
			grids[1].loadSection()
			grids[2].curSection = curSection+1
			grids[2].loadSection()
	
			if curSection < 0:
				curSection = 0
			if curSection > SONG.notes.size():
				SONG.notes.append({
					"lengthInSteps": 16,
					"bpm": SONG.bpm,
					"changeBPM": false,
					"mustHitSection": SONG.notes[curSection - 1].mustHitSection,
					"sectionNotes": [],
					"altAnim": false
				})
			
			emit_signal("changed_section")
			
			Conductor.songPosition = grids[1].section_start_time()
			
			if not "changeBPM" in SONG.notes[curSection]:
				SONG.notes[curSection].changeBPM = false
			
			if not "bpm" in SONG.notes[curSection]:
				SONG.notes[curSection].bpm = SONG.bpm
				
	var a:float = int((Conductor.songPosition) - grids[1].section_start_time()) % int(Conductor.timeBetweenSteps * SONG.notes[grids[1].curSection].lengthInSteps)
	camera.position.y = grids[1].time_to_y(a)
		
func _on_IsPixelStage_pressed():
	SONG.pixelStage = $TabContainer/Art/IsPixelStage.pressed

func opponentSelect(index):
	SONG.player2 = characterList[index]

func gfSelect(index):
	SONG.gf = characterList[index]

func playerSelect(index):
	SONG.player1 = characterList[index]

func stageSelect(index):
	SONG.stage = stageList[index]

func uiSkinSelect(index):
	SONG.uiSkin = uiSkinList[index]

func changeSongBPM(value):
	SONG.bpm = float(value)

func changeSongScrollSpeed(value):
	SONG.speed = float(value)

func onSongTextBoxChanged(new_text):
	SONG.song = new_text

func onDifficultyTextBoxChange(new_text):
	PlayStateSettings.difficulty = new_text

func _on_ReloadJSON_pressed():
	PlayStateSettings.SONG = CoolUtil.getJSON(Paths.songJSON(SONG.song, PlayStateSettings.difficulty))
	Scenes.switchScene("ChartEditor")
