extends Option

onready var title = $text

export(int) var decimals_lol:int = 1

export(float) var multiplier:float = 1.0
export(Array) var limits:Array = [0, 0]

func _ready():
	title.text = name

func _physics_process(delta):
	var ass = Options.get_data(option)
	ass = CoolUtil.round_decimal(ass, decimals_lol)
	
	title.text = name + "        " + str(Options.get_data(option))
