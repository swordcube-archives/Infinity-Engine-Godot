tool
extends Node2D

export(int) var rows = 16
export(int) var columns = 8

export(float) var grid_size = 40.0

onready var square = $square

onready var separator1 = $Separator1
onready var separator2 = $Separator2

var selected_x:int = 0
var selected_y:int = 0

var note_snap = 16

var mouse_pos:Vector2

func _draw():
	var dark = false
	
	for x in columns + 1:
		dark = !dark
		
		if (x * grid_size) + position.x > 1280:
			break
		if (x * grid_size) + position.x < 0 - grid_size:
			continue
		
		for y in rows:
			draw_box(x,y,dark)
			
			dark = !dark
			
			if (y * grid_size) + position.y > 720:
				break
			if (y * grid_size) + position.y < 0 - grid_size:
				continue
				
func draw_box(x, y, is_dark):
	var cool_color = Color(0.9, 0.9, 0.9)
	
	if is_dark:
		cool_color = Color(0.835, 0.835, 0.835)
	
	draw_rect(Rect2(Vector2(x * grid_size, y * grid_size), Vector2(grid_size, grid_size)), cool_color, true)
