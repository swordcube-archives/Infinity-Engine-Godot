extends Option

onready var title = $text

var decimals_lol:int = 1

var multiplier:float = 1.0
var limits:Array = [0, 0]

var values:Array = []

func _physics_process(delta):
	var ass = Options.get_data(option)
	
	if not ass is String:
		ass = CoolUtil.round_decimal(ass, decimals_lol)
	
	title.text = option_title + "        " + str(Options.get_data(option))
