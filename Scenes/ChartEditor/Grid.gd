extends Node2D

var columns = 8
var rows = 16

var grid_size = 40

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
