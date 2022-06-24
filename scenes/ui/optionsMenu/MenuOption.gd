tool
extends GenericOption

class_name MenuOption

var oldText:String = ""

export(bool) var transitionToScene:bool = true
export(String) var menuToUse:String = ""

func _ready():
	$AnimationPlayer.play("default")

func _process(delta):
	if not isTool and targetY == 0 and Input.is_action_just_pressed("ui_accept"):
		Scenes.switchScene(menuToUse, transitionToScene)
		
	if oldText != name:
		oldText = name
		$Option.text = name
