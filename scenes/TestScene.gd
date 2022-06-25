extends Node2D

onready var animSpr = $AnimatedSprite
onready var line2d = $Line2D

var image
var tex:ImageTexture

func _ready():
	var sustainTexture = animSpr.frames.get_frame(animSpr.animation, animSpr.frame)
		
	image = sustainTexture.get_data()
	image.lock()
	
	rotate_image()
	
	image.unlock()
	
	tex = ImageTexture.new()
	tex.create_from_image(image)
	
	line2d.texture = tex

func rotate_image():
	var tex = image

	var trans = Transform2D()

	trans = trans.rotated(PI/2.0)

	var p1 = trans.basis_xform(Vector2(0,0))
	var p2 = trans.basis_xform(Vector2(tex.get_width(),0))
	var p3 = trans.basis_xform(Vector2(tex.get_width(),tex.get_height() - 4))
	var p4 = trans.basis_xform(Vector2(0,tex.get_height() - 4))

	var ps = [p2,p3,p4]
	var minx = p1.x
	var miny = p1.y
	var maxx = p1.x
	var maxy = p1.y

	for p in ps:
		if p.x < minx:
			minx = p.x

		if p.x > maxx:
			maxx = p.x

		if p.y < miny:
			miny = p.y

		if p.y > maxy:
			maxy = p.y

	var img = Image.new()

	img.create(maxx - minx, maxy - miny , false, Image.FORMAT_RGBA8)

	tex.lock()
	img.lock()

	for x in tex.get_width():
		for y in tex.get_height():
			var color = tex.get_pixel(x, y)
			
			var p = trans.basis_xform(Vector2(x,y))
			
			p.x = round(p.x)
			p.y = round(p.y)
			
			p = p - Vector2(minx, miny)
			
			img.set_pixelv(p, color)
	
	img.unlock()
	tex.unlock()
	
	image = img
