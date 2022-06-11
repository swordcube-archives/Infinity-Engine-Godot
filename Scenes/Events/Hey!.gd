extends Event

func on_event():
	if not Options.get_data("optimization"):
		var c:Node2D = get_character_from_argument(params["Character"])
		c.play_anim("hey", true)
		c.special_anim = true
