tool
extends MenuOption

class_name ArrayOption

var oldText:String = ""

var oldValue:String = ""
var value:String = "null"

var curOption:int = 0

var holdTimer:float = 0

export(PoolStringArray) var options:PoolStringArray = []

func _ready():
	$AnimationPlayer.play("default")
	value = Preferences.getOption(saveDataOption)
	curOption = stringArrayFind(options, value)

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
				if vector.x == -1:
					var c = curOption-1
					if c < 0:
						c = options.size()-1
					curOption = c
					value = options[c]
					Preferences.setOption(saveDataOption, value)
					
				if vector.x == 1:
					var c = curOption+1
					if c > options.size()-1:
						c = 0
					curOption = c
					value = options[c]
					Preferences.setOption(saveDataOption, value)
		else:
			holdTimer = 0
		
	if oldText != name:
		oldText = name
		$Option.text = name
		
	$Value.rect_position.x = $Option.rect_position.x + $Option.rect_size.x * 1.35
	if oldValue != value:
		oldValue = value
		$Value.text = value
		
func stringArrayFind(stringArray:PoolStringArray, item:String):
	var resultIndex:int = -1
	var index:int = 0
	for thing in stringArray:
		if thing == item:
			resultIndex = index
			return resultIndex
		index += 1
		
	return -1
