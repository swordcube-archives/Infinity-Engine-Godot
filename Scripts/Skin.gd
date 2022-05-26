extends Node

export(StreamTexture) var ready_tex = preload("res://Assets/Images/UI Skins/Default/ready.png")
export(StreamTexture) var set_tex = preload("res://Assets/Images/UI Skins/Default/set.png")
export(StreamTexture) var go_tex = preload("res://Assets/Images/UI Skins/Default/go.png")

export(StreamTexture) var marvelous_tex = preload("res://Assets/Images/UI Skins/Default/marvelous.png")
export(StreamTexture) var sick_tex = preload("res://Assets/Images/UI Skins/Default/sick.png")
export(StreamTexture) var good_tex = preload("res://Assets/Images/UI Skins/Default/good.png")
export(StreamTexture) var bad_tex = preload("res://Assets/Images/UI Skins/Default/bad.png")
export(StreamTexture) var shit_tex = preload("res://Assets/Images/UI Skins/Default/shit.png")
export(StreamTexture) var combo_tex = preload("res://Assets/Images/UI Skins/Default/combo.png")

export(String) var sustain_tex = "res://Assets/Images/UI Skins/Default/Sustains/hold.png"
export(String) var sustain_end_tex = "res://Assets/Images/UI Skins/Default/Sustains/tail.png"

export(SpriteFrames) var strum_tex = preload("res://Assets/Images/UI Skins/Default/strums.res")
export(SpriteFrames) var note_tex = preload("res://Assets/Images/UI Skins/Default/notes.res")
export(SpriteFrames) var note_splash_tex = preload("res://Assets/Images/UI Skins/Default/noteSplashes.res")

export(AudioStream) var countdown_3 = preload("res://Assets/Sounds/Countdown/default/intro3-default.ogg")
export(AudioStream) var countdown_2 = preload("res://Assets/Sounds/Countdown/default/intro2-default.ogg")
export(AudioStream) var countdown_1 = preload("res://Assets/Sounds/Countdown/default/intro1-default.ogg")
export(AudioStream) var countdown_go = preload("res://Assets/Sounds/Countdown/default/introGo-default.ogg")

export(String) var sustain_path = "res://Assets/Images/UI Skins/Default/Sustains"
export(String) var combo_num_path = "res://Assets/Images/UI Skins/Default/num"

export(float) var strum_scale = 1.0
export(float) var note_scale = 1.0
export(float) var rating_scale = 1.0
