extends Node2D

onready var icon:Sprite = $Icon

onready var title:Label = $Title
onready var desc:Label = $ScrollContainer/Description

onready var checkbox:Node2D = $Checkbox
onready var status:Label = $Checkbox/Status

var xAdd:float = 0
var yAdd:float = 0

var isMenuItem:bool = false
var targetY:float = 0

var mod:String = ""

func _ready():
	checkbox.enabled = Preferences.getOption("mods")[mod]
	checkbox.refresh()
	updateStatus()
	doYourMom(0.0, true)

func _process(delta):
	doYourMom(delta)
		
	if targetY == 0 and Input.is_action_just_pressed("ui_accept"):
		var yourMom = Preferences.getOption("mods").duplicate()
		yourMom[mod] = !yourMom[mod]
		Preferences.setOption("mods", yourMom)
		checkbox.enabled = Preferences.getOption("mods")[mod]
		updateStatus()
		
func doYourMom(delta:float = 0.0, qwertyuiop:bool = false):
	if isMenuItem:
		var scaleVal:float = 1 if targetY == 0 else 0.85
		if qwertyuiop:
			scale.x = scaleVal
			scale.y = scale.x
			#position.y = (targetY * 324) + yAdd
		else:
			var lerpVal:float = MathUtil.boundTo(delta * 9.6, 0, 1)
			scale.x = lerp(scale.x, scaleVal, lerpVal)
			scale.y = scale.x
			position.y = lerp(position.y, (targetY * 324) + yAdd, lerpVal)
		
func updateStatus():
	status.text = "ON" if checkbox.enabled else "OFF"
