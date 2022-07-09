extends Sprite

var colors:Array = [
	Color("ffffff"),
	Color("00ffff"),
]

var ogColors:Array = colors.duplicate()

var flashing:bool = false
var flashTimer:float = 0.0

var targetY:int = 0

func _ready():
	_process(0)
	
func _process(delta):
	position.y = lerp(position.y, (targetY * 120) + 525, MathUtil.getLerpValue(0.17, delta))
	modulate = colors[0]
	modulate.a = 1 if targetY == 0 else 0.6
	if flashing:
		flashTimer += delta
		
		if flashTimer > 0.02:
			flashTimer = 0.0
			colors.invert()
	else:
		colors = ogColors.duplicate()
