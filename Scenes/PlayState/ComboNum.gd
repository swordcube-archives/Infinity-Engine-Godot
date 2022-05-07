extends Sprite

var yvel:float = rand_range(3, 5)
var your:bool = false

func _ready():
	yield(get_tree().create_timer((Conductor.crochet / 1000) * 1.5), "timeout")
	your = true

func _process(delta):
	position.y -= yvel
	yvel -= delta * 10
	
	if your:
		modulate.a -= delta * 5
		if modulate.a < 0:
			modulate.a = 0
			queue_free()
