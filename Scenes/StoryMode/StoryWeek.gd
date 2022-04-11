extends Sprite

var week_name = "tutorial"
var flashing = false

var color_array = ["FFFFFF", "00ffff"]

var timer = Timer.new()

func start_flashing():
	flashing = true

	timer.set_wait_time(0.05)
	add_child(timer)
	timer.start()
	
func _process(delta):
	if flashing:
		yield(timer, "timeout")
		color_array.invert()
		modulate = Color(color_array[0])