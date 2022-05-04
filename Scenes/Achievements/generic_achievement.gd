extends Node

export(String) var title = "Template Achievement"
export(String) var internal_name = "template"
export(String) var description = "Duplicate this achievement to make new ones!"
export(StreamTexture) var icon = preload("res://Assets/Images/Achievements/unknown.png")
export(String) var unlocks_after_week = "example"
export(bool) var custom_requirement = false
export(int) var achievement_order = -1
export(bool) var hidden = false
