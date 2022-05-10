extends Node2D

onready var gf = $gf
onready var bf = $bf

onready var cam = $Camera2D

onready var theRating = $hud/RatingExample
onready var theCombo = $hud/RatingExample/Combo

onready var ratingLol = $hud/TabNotif/Label2
onready var label3 = $hud/TabNotif/Label3

onready var music = AudioHandler.get_node("Music/optionsMenu")

var changing_combo:bool = false

onready var offsets:Dictionary = {
	"rating": Options.get_data("rating-offset"),
	"combo": Options.get_data("combo-offset"),
}

func _ready():
	Conductor.change_bpm(125)
	Conductor.song_position = -150
	Conductor.connect("beat_hit", self, "beat_hit")
	AudioHandler.play_music("optionsMenu")
	
	theRating.position = Vector2(654, 237)
	
	theRating.position += Vector2(offsets["rating"][0], offsets["rating"][1])
	theCombo.position += Vector2(offsets["combo"][0], offsets["combo"][1])
	
func _process(delta):
	if Input.is_action_just_pressed("ui_focus_next"):
		changing_combo = not changing_combo
		
	cam.zoom = lerp(cam.zoom, Vector2(1.1, 1.1), delta * 7)
	Conductor.song_position = (music.get_playback_position() * 1000.0) - Options.get_data("note-offset")
	
	if changing_combo:
		ratingLol.text = "Combo"
	else:
		ratingLol.text = "Rating"
		
	if Input.is_action_just_pressed("ui_back"):
		SceneHandler.switch_to("OptionsMenu")
	
	if Input.is_action_just_pressed("ui_left"):
		change_thing(-10)
		
	if Input.is_action_just_pressed("ui_right"):
		change_thing(10)
		
	if Input.is_action_just_pressed("ui_up"):
		change_thing(-10, true)
		
	if Input.is_action_just_pressed("ui_down"):
		change_thing(10, true)
		
	label3.text = "Rating Offset: " + str(offsets["rating"])
	label3.text += "\nCombo Offset: " + str(offsets["combo"])
		
func change_thing(amount:int = 0, y_pos:bool = false):
	if changing_combo:
		var fard:int = 0
		if y_pos:
			fard = 1
			
		offsets["combo"][fard] += amount
		theCombo.position = Vector2(offsets["combo"][0], offsets["combo"][1])
		Options.set_data("combo-offset", offsets["combo"])
	else:
		var fard:int = 0
		if y_pos:
			fard = 1
			
		offsets["rating"][fard] += amount
		theRating.position = Vector2(654, 237) + Vector2(offsets["rating"][0], offsets["rating"][1])
		Options.set_data("rating-offset", offsets["rating"])
	
func beat_hit():
	gf.dance()
	bf.dance()
	
	if Conductor.cur_beat % 4 == 0:
		cam.zoom -= Vector2(0.03, 0.03)
