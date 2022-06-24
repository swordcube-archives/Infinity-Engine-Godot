tool
extends GenericOption

class_name BoolOption

var oldText:String = ""

func _ready():
	$AnimationPlayer.play("default")

func _process(delta):
	if oldText != name:
		oldText = name
		$Label.text = name
		$Label.rect_size.x = 0
		
	if not isTool and targetY == 0 and Input.is_action_just_pressed("ui_accept"):
		Preferences.setOption(saveDataOption, not Preferences.getOption(saveDataOption))
		$Checkbox.enabled = Preferences.getOption(saveDataOption)
		$Checkbox.refresh()
		
		OS.vsync_enabled = Preferences.getOption(saveDataOption)
