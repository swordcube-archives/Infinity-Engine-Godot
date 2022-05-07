extends Node2D

onready var PlayState = $"../../../../"

onready var spr = $spr
onready var num_template = $Combo/NumTemplate
var combo_str:String = "0"

var yvel:float = 5.0

var kill_spr:bool = false
var kill_combo:bool = false

func _ready():
	combo_str = str(PlayState.combo)
	
	match len(combo_str):
		1:
			combo_str = "00" + combo_str
		2:
			combo_str = "0" + combo_str
	
	for i in len(combo_str):
		var new_num = num_template.duplicate()
		new_num.position.x += (i * 65)
		new_num.visible = true
		new_num.texture = PlayState.combo_textures[int(combo_str[i])]
		add_child(new_num)
	
	rating_timer()
	combo_timer()
	
func _physics_process(delta):
	spr.position.y -= yvel
	yvel -= delta * 20
	
	if kill_spr:
		spr.modulate.a -= delta * 5
		if spr.modulate.a < 0:
			spr.modulate.a = 0
			
	if kill_combo:
		queue_free()
	
func rating_timer():
	yield(get_tree().create_timer(Conductor.crochet / 1000), "timeout")
	kill_spr = true
	
func combo_timer():
	yield(get_tree().create_timer((Conductor.crochet / 1000) * 2.5), "timeout")
	kill_combo = true
