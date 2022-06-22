extends Modchart

var noBitches:float = 0.0

func _process(delta):
	noBitches += 80 * delta
	PlayState.HUD.modulate.color.a = MathUtil.boundTo(1 - sin((PI * noBitches) / 180), 0, 1)
