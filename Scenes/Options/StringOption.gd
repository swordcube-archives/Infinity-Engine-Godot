extends Option

onready var title = $text

export(Array) var values:Array = []

func _ready():
	title.text = name

func _physics_process(delta):
	var ass = Options.get_data(option)
	
	title.text = name + "        " + str(Options.get_data(option))
