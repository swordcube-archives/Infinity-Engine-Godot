extends MenuOption

var oldText:String = "???"
export(String) var text:String = ""

var targetX:int = 0

func _ready():
	$AnimationPlayer.play("default")
	position.x = targetX * 1280

func _process(delta):
	if oldText != text:
		oldText = text
		$Label.text = text
		
	position.x = lerp(position.x, targetX * 1280, MathUtil.getLerpValue(0.35, delta))
