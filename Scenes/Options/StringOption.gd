extends Option

onready var title = $text

var multiplier:float = 1.0
var limits:Array = [0, 0]

var values:Array = []

func _physics_process(delta):
	title.text = option_title + "        " + str(Options.get_data(option))
