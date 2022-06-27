tool
extends GenericOption

class_name NumberOption

var oldText:String = ""

var oldValue:String = ""
var value:String = "null"

export(float) var min_value:float = 0.0
export(float) var max_value:float = 1.0

export(float) var multiplier:float = 0.1
export(int) var decimalCount:int = 1

var holdTimer:float = 0.0

func _ready():
	$AnimationPlayer.play("default")
	value = str(Preferences.getOption(saveDataOption))

func _process(delta):
	if not isTool and optionNeeded != "":
		if Preferences.getOption(optionNeeded) == neededValue[0]:
			$Option.modulate.a = 1
			$Value.modulate.a = 1
		else:
			$Option.modulate.a = 0.3
			$Value.modulate.a = 0.3
	else:
		$Option.modulate.a = 1
		$Value.modulate.a = 1
		
	if not isTool:
		var canModify:bool = true
		if optionNeeded != "":
			canModify = Preferences.getOption(optionNeeded) == neededValue[0]
		var vector:Vector2 = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
		if canModify and targetY == 0 and vector.x != 0:
			holdTimer += delta
			if (Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right")) or holdTimer > 0.5:
				var floatValue:float = float(value)
				floatValue += vector.x * multiplier
				floatValue = MathUtil.roundDecimal(MathUtil.boundTo(floatValue, min_value, max_value), decimalCount)
				Preferences.setOption(saveDataOption, floatValue)
				value = str(floatValue)
				onChangeValue(floatValue)
				yield(get_tree().create_timer(0.05), "timeout")
		else:
			holdTimer = 0.0
		
	if oldText != name:
		oldText = name
		$Option.text = name
		
	$Value.rect_position.x = $Option.rect_position.x + $Option.rect_size.x * 1.35
	if oldValue != value:
		oldValue = value
		$Value.text = value

func onChangeValue(_v):
	pass
