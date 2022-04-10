extends Node2D

var y_vel = 3
var br = 0

var combo = 0

var combo_array = [0, 0, 0, 0]

var note_ms = 0.0

var rand_array = []

func _ready():
	$MS.text = str(note_ms) + "ms"
	
	for i in 4:
		rand_array.append(rand_range(3, 4))
		
	# load combo textures
	get_combo()
	#print(combo_array)
	
	if len(str(combo)) == 4:
		$Num0.texture = load(number_path(combo_array[0]))
		$Num1.texture = load(number_path(combo_array[1]))
		$Num2.texture = load(number_path(combo_array[2]))
		$Num3.texture = load(number_path(combo_array[3]))
	else:
		$Num0.texture = load(number_path(combo_array[1]))
		$Num1.texture = load(number_path(combo_array[2]))
		$Num2.texture = load(number_path(combo_array[3]))
	
	$Sprite.position = Vector2(0, 0)
	
	for i in 4:
		get_node("Num" + str(i)).position = Vector2(-164 + (i * 45), 118)
	
	var rating_position = Options.get_data("rating-position")
	
	global_position = Vector2(rating_position[0], rating_position[1])

func _physics_process(delta):
	$Sprite.position.y -= y_vel
	
	for i in len(rand_array):
		get_node("Num" + str(i)).position.y -= rand_array[i]
		rand_array[i] -= 0.2
	
	br += delta * 4
	y_vel -= 0.2
	
	if br > 2:
		modulate.a -= delta * 5
		
	if modulate.a <= 0:
		queue_free()
		
func get_combo():
	$Num3.visible = false
	
	match(len(str(combo))):
		4:
			$Num3.visible = true
			combo_array = [str(combo)[0], str(combo)[1], str(combo)[2], str(combo)[3]]
		3:
			combo_array = [0, str(combo)[0], str(combo)[1], str(combo)[2]]
		2:
			combo_array = [0, 0, str(combo)[0], str(combo)[1]]
		1:
			combo_array = [0, 0, 0, str(combo)[0]]
		_:
			combo_array = [0, 0, 0, str(combo)[0]]
		
func number_path(num):
	return "res://Assets/Images/UI Skins/" + Gameplay.ui_Skin + "/num" + str(num) + ".png"
