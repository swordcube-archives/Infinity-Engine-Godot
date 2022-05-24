extends Option

onready var title = $text
onready var menu = $text.text

export(String) var menu_to_load:String = ""
export(String) var menu_category:String = ""

func _ready():
	title.text = name
