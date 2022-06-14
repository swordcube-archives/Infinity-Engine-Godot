extends Node

export(StreamTexture) var ready_tex = preload("res://assets/images/ui/skins/arrows/countdown/ready.png")
export(StreamTexture) var set_tex = preload("res://assets/images/ui/skins/arrows/countdown/set.png")
export(StreamTexture) var go_tex = preload("res://assets/images/ui/skins/arrows/countdown/go.png")

export(StreamTexture) var marvelous_tex = preload("res://assets/images/ui/skins/arrows/ratings/marvelous.png")
export(StreamTexture) var sick_tex = preload("res://assets/images/ui/skins/arrows/ratings/sick.png")
export(StreamTexture) var good_tex = preload("res://assets/images/ui/skins/arrows/ratings/good.png")
export(StreamTexture) var bad_tex = preload("res://assets/images/ui/skins/arrows/ratings/bad.png")
export(StreamTexture) var shit_tex = preload("res://assets/images/ui/skins/arrows/ratings/shit.png")

export(AudioStream) var countdown_3 = preload("res://assets/sounds/ui/skins/countdown/arrows/intro3.ogg")
export(AudioStream) var countdown_2 = preload("res://assets/sounds/ui/skins/countdown/arrows/intro2.ogg")
export(AudioStream) var countdown_1 = preload("res://assets/sounds/ui/skins/countdown/arrows/intro1.ogg")
export(AudioStream) var countdown_go = preload("res://assets/sounds/ui/skins/countdown/arrows/introGo.ogg")

export(SpriteFrames) var strum_tex = preload("res://assets/images/ui/skins/arrows/strums.res")
export(SpriteFrames) var note_tex = preload("res://assets/images/ui/skins/arrows/notes.res")
export(SpriteFrames) var note_splash_tex = preload("res://assets/images/ui/skins/arrows/noteSplashes.res")

export(String) var health_bar_path = "res://scenes/ui/playState/healthBar/skins/arrows/HealthBar.tscn"

export(float) var strum_scale = 1
export(float) var note_scale = 1
export(float) var note_splash_scale = 0.6
