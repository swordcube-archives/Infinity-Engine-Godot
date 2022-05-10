extends TouchScreenButton

var default:float = 0.2

func _ready():
	modulate.a = default

func _physics_process(delta):
	modulate.a = lerp(modulate.a, default, delta * 7)
