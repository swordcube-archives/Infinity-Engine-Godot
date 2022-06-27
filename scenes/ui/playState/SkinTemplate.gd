extends Node

export(StreamTexture) var ready_tex = preload("res://assets/images/ui/skins/arrows/countdown/ready.png")
export(StreamTexture) var set_tex = preload("res://assets/images/ui/skins/arrows/countdown/set.png")
export(StreamTexture) var go_tex = preload("res://assets/images/ui/skins/arrows/countdown/go.png")

export(StreamTexture) var marvelous_tex = preload("res://assets/images/ui/skins/arrows/ratings/marvelous.png")
export(StreamTexture) var sick_tex = preload("res://assets/images/ui/skins/arrows/ratings/sick.png")
export(StreamTexture) var good_tex = preload("res://assets/images/ui/skins/arrows/ratings/good.png")
export(StreamTexture) var bad_tex = preload("res://assets/images/ui/skins/arrows/ratings/bad.png")
export(StreamTexture) var shit_tex = preload("res://assets/images/ui/skins/arrows/ratings/shit.png")

export(StreamTexture) var combo_0 = preload("res://assets/images/ui/skins/arrows/combo/num0.png")
export(StreamTexture) var combo_1 = preload("res://assets/images/ui/skins/arrows/combo/num1.png")
export(StreamTexture) var combo_2 = preload("res://assets/images/ui/skins/arrows/combo/num2.png")
export(StreamTexture) var combo_3 = preload("res://assets/images/ui/skins/arrows/combo/num3.png")
export(StreamTexture) var combo_4 = preload("res://assets/images/ui/skins/arrows/combo/num4.png")
export(StreamTexture) var combo_5 = preload("res://assets/images/ui/skins/arrows/combo/num5.png")
export(StreamTexture) var combo_6 = preload("res://assets/images/ui/skins/arrows/combo/num6.png")
export(StreamTexture) var combo_7 = preload("res://assets/images/ui/skins/arrows/combo/num7.png")
export(StreamTexture) var combo_8 = preload("res://assets/images/ui/skins/arrows/combo/num8.png")
export(StreamTexture) var combo_9 = preload("res://assets/images/ui/skins/arrows/combo/num9.png")

export(AudioStream) var countdown_3 = preload("res://assets/sounds/ui/skins/countdown/arrows/intro3.ogg")
export(AudioStream) var countdown_2 = preload("res://assets/sounds/ui/skins/countdown/arrows/intro2.ogg")
export(AudioStream) var countdown_1 = preload("res://assets/sounds/ui/skins/countdown/arrows/intro1.ogg")
export(AudioStream) var countdown_go = preload("res://assets/sounds/ui/skins/countdown/arrows/introGo.ogg")

export(SpriteFrames) var strum_tex = preload("res://assets/images/ui/skins/arrows/strums.res")
export(SpriteFrames) var note_tex = preload("res://assets/images/ui/skins/arrows/notes.res")
export(SpriteFrames) var note_splash_tex = preload("res://assets/images/ui/skins/arrows/noteSplashes.res")

export(String) var sustain_tex_path = "res://assets/images/ui/skins/arrows/sustains"
export(String) var health_bar_path = "res://scenes/ui/playState/healthBar/skins/default/HealthBar.tscn"
export(String) var time_bar_path = "res://scenes/ui/playState/timeBar/skins/default/TimeBar.tscn"

export(float) var rating_scale = 0.7
export(float) var combo_scale = 0.5
export(float) var countdown_scale = 1

export(float) var strum_scale = 1
export(float) var note_scale = 1
export(float) var sustain_scale = 1
export(float) var sustain_end_offset = 0

export(float) var note_splash_scale = 0.6
