extends Stage

func create():
	if PlayStateSettings.SONG.song.song.to_lower() == "roses":
		$ParallaxBackground/layer4/bgGirls.play("BG fangirls dissuaded")
