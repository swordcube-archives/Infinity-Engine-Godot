extends Node2D

onready var label = $Label
onready var input = $LineEdit

onready var charter = $"../../../../../"

var event_data

func _on_LineEdit_text_changed(new_text):
	charter.event_data.params[label.text] = new_text
	charter.song.events[charter.selected_section][charter.kill_me][1] = charter.event_data
	
	print(charter.song.events[charter.selected_section][charter.kill_me][1].params)

func _on_LineEdit_focus_entered():
	charter.can_interact = false

func _on_LineEdit_focus_exited():
	charter.can_interact = true
