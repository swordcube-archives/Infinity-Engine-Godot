extends Node2D

var health:float = 1.0

var SONG

var gfVersion:String

var dad:Node2D
var gf:Node2D
var boyfriend:Node2D

var songScore:int = 0
var songMisses:int = 0
var songAccuracy:float = 0.0

var defaultCamZoom:float = 0.5

func _ready():
	if(Gameplay.SONG == null): # load tutorial if the song can't be found
		var song = "res://Assets/Songs/Tutorial/hard"
		print("SONG TO LOAD: " + song)
		Gameplay.SONG = JsonUtil.get_json(song)
		
	SONG = Gameplay.SONG.song
			
	Conductor.songPosition = 0
	Conductor.curBeat = 0
	Conductor.curStep = 0
	Conductor.change_bpm(Gameplay.SONG.song.bpm)
	Conductor.connect("beat_hit", self, "beat_hit")
	
	$Misc/Transition._fade_out()
	
	# add dad
	var dadLoaded = load("res://Characters/" + SONG.player2.to_lower() + "/char.tscn")
	
	if dadLoaded == null:
		dadLoaded = load("res://Characters/dad/char.tscn")
	
	dad = dadLoaded.instance()
	dad.position = Vector2(640, 360)
	$camHUD.get_node("BG").add_child(dad)
	
	# add gf
	match(SONG.song.to_lower()):
		"tutorial", "bopeebo", "fresh", "dad battle":
			gfVersion = "gf"
		"spookeez", "south", "monster":
			gfVersion = "gf"
		"pico", "philly nice", "blammed":
			gfVersion = "gf"
		"satin panties", "high", "m.i.l.f":
			gfVersion = "gf"
		"cocoa", "eggnog", "winter horrorland":
			gfVersion = "gf"
		"senpai", "roses", "thorns":
			gfVersion = "gf-pixel"
		_:
			gfVersion = SONG.gfVersion
		
	var gfLoaded = load("res://Characters/" + gfVersion.to_lower() + "/char.tscn")
	
	if gfLoaded == null:
		gfLoaded = load("res://Characters/dad/char.tscn")
	
	gf = gfLoaded.instance()
	gf.position = Vector2(640, 360)
	$camHUD.get_node("BG").add_child(gf)
	
	# add boyfriend
	var bfLoaded = load("res://Characters/" + SONG.player1.to_lower() + "/char.tscn")
	
	if bfLoaded == null:
		bfLoaded = load("res://Characters/dad/char.tscn")
	
	boyfriend = bfLoaded.instance()
	boyfriend.position = Vector2(640, 360)
	$camHUD.get_node("BG").add_child(boyfriend)
	
	dad.play_anim("idle")
	
	change_dad_icon(dad.health_icon)
	change_bf_icon(boyfriend.health_icon)
	
	change_dad_health_color(dad.health_color)
	change_bf_health_color(boyfriend.health_color)
	
	$camGame.position = Vector2((dad.position.x - 640) - dad.camera_pos_x, (dad.position.y - 360) + dad.camera_pos_y)
	$camHUD.get_node("BG").scale = Vector2(defaultCamZoom, defaultCamZoom)
	
func change_dad_icon(texture):
	$camHUD/HealthBar/IconP2.texture = texture
	
func change_bf_icon(texture):
	$camHUD/HealthBar/IconP1.texture = texture
	
func change_dad_health_color(color):
	$camHUD/HealthBar/DadColor.color = color
	
func change_bf_health_color(color):
	$camHUD/HealthBar/BFColor.color = color
	
func _process(delta):
	Conductor.songPosition += (delta * 1000)
	
	$camHUD/ScoreText.bbcode_text = "[center]Score: " + str(songScore) + " // Misses: " + str(songMisses) + " // Accuracy: " + str(Util.round_decimal(songAccuracy, 2)) + "%"
	
	$camHUD/HealthBar/BFColor.rect_scale.x = health / 2
	
	camera_zooms(delta)
	icon_zooms(delta)
	
	#health += 0.002
	if health < 0:
		health = 0
	if health > 2:
		health = 2
		
	key_shit()
	
func camera_zooms(delta):
	# cam game zoom
	var camGameZoomX = lerp($camGame.zoom.x, 1, delta * 7)
	var camGameZoomY = lerp($camGame.zoom.y, 1, delta * 7)
	
	$camGame.zoom = Vector2(camGameZoomX, camGameZoomY)
	
	# cam hud zoom
	var camHUDZoomX = lerp($camHUD.zoom.x, 1, delta * 7)
	var camHUDZoomY = lerp($camHUD.zoom.y, 1, delta * 7)
	
	$camHUD.zoom = Vector2(camHUDZoomX, camHUDZoomY)
	
func icon_zooms(delta):
	var iconScaleX = lerp($camHUD/HealthBar/IconP2.scale.x, 1, delta * 15)
	var iconScaleY = lerp($camHUD/HealthBar/IconP2.scale.y, 1, delta * 15)
	
	$camHUD/HealthBar/IconP2.scale = Vector2(iconScaleX, iconScaleY)
	$camHUD/HealthBar/IconP1.scale = Vector2(0 - iconScaleX, iconScaleY)
	
	var iconOffset:int = 26
	var healthBar = $camHUD/HealthBar/BFColor
	
	var healthPercentage = (health / 2) * 100
	
	$camHUD/HealthBar/IconP1.position.x = ((healthBar.rect_position.x + healthBar.rect_pivot_offset.x) - ((healthBar.rect_scale.x * 600) - 60)) + ((abs($camHUD/HealthBar/IconP1.scale.x) - 1) * 80)
	$camHUD/HealthBar/IconP2.position.x = ($camHUD/HealthBar/IconP1.position.x - 105) - ((abs($camHUD/HealthBar/IconP1.scale.x) - 1) * 150)
	
func key_shit():
	var directions = ["LEFT", "DOWN", "UP", "RIGHT"]
	var letter_directions = ["A", "B", "C", "D"]

	var strum_index = 0
	for strum in $camHUD/PlayerStrums.get_children():
		if Input.is_action_just_pressed(strum.name):
			strum.play(letter_directions[strum_index] + " press")
	
		if Input.is_action_just_released(strum.name):
			strum.play("arrow" + directions[strum_index])
			
		strum_index += 1
	
func beat_hit():
	if !dad.get_node("anim").is_playing():
		dad.dance()
		
	gf.dance()
	
	if !boyfriend.get_node("anim").is_playing():
		boyfriend.dance()
	
	$camHUD/HealthBar/IconP2.scale = Vector2(1.2, 1.2)
	$camHUD/HealthBar/IconP1.scale = Vector2(-1.2, 1.2)
	
	if Conductor.curBeat % 4 == 0:
		$camHUD.zoom = Vector2(0.97, 0.97)
		
func remap_to_range(value, start1, stop1, start2, stop2):
	return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1))
