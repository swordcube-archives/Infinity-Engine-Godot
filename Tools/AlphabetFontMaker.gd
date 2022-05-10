extends Node2D

func _ready():
	var font = BitmapFont.new()
	var texture = load("res://Assets/Fonts/alphabet.png")
	var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ, 0123456789-.:@_!()+<>*&?"
	var chars_lower = chars.to_lower()
	font.height = 87
	font.add_texture(texture)
	for i in range (0, chars.length()):
		var spacing = 46
		match chars[i]:
			"A", "+", "G":
				spacing = 50
			" ", "L":
				spacing = 40
			"T":
				spacing = 44
			"E":
				spacing = 43
			"(", ".", "!", "&":
				spacing = 28
				
		font.add_char(chars.ord_at(i), 0, Rect2(87 * i, 0, 87, 87), Vector2(-25, 0), spacing)
		# allows you to type in lowercase if you want
		font.add_char(chars_lower.ord_at(i), 0, Rect2(87 * i, 0, 87, 87), Vector2(-25, 0), spacing)
	
	$Label.add_font_override("font", font)
	ResourceSaver.save("res://Assets/Fonts/font_alphabet.tres", font)
	$Label.text = "Done!"
