extends Node2D

class_name Note

var downScroll:bool = false

onready var spr = $spr
onready var end = $end
onready var line2d = $Line2D

onready var attachedStrum:Node2D = $"../../"

export(String) var direction:String = "A"
export(float) var strumTime:float = 0.0

var altNote:bool = false

var mustPress:bool = false

var beingPressed:bool = false

var noteData:int = 0

var ogSustainLength:float = 0.0
var sustainLength:float = 0.0

var timeBetweenBeats:float = Conductor.timeBetweenBeats
var timeBetweenSteps:float = Conductor.timeBetweenSteps

var image:Image
var tex:ImageTexture

func _ready():
	if spr.frames == CoolUtil.nullRes:
		spr.frames = PlayStateSettings.currentUiSkin.note_tex
		
	if end.frames == CoolUtil.nullRes:
		end.frames = PlayStateSettings.currentUiSkin.note_tex
		
	spr.play(direction + " hold")
	var sustainTexture = spr.frames.get_frame(spr.animation, spr.frame)
		
	image = sustainTexture.get_data()
	image.lock()
	
	rotateImage()
	
	image.unlock()
	
	tex = ImageTexture.new()
	tex.create_from_image(image)
	
	match Preferences.getOption("clip-style"):
		"StepMania":
			line2d.z_index = -1
			end.z_index = -1
			
	line2d.texture = tex
	line2d.width = tex.get_width()*1.2
	
	end.modulate.a = 0.6
	end.play(direction + " tail")
		
	var ss = PlayStateSettings.currentUiSkin.strum_scale
	spr.scale = Vector2(ss, ss)
		
	refreshAnim()
	
	line2d.position.y = 0
	
func _process(delta):
	line2d.scale.y = spr.scale.y
	var yPos:float = ((sustainLength / 1.5) * PlayStateSettings.scrollSpeed) / (spr.scale.y + 0.3)
	if downScroll:
		line2d.points[1].y = -yPos
		end.position.y = line2d.points[1].y - (end.frames.get_frame(end.animation, end.frame).get_height() / 2)
	else:
		line2d.points[1].y = yPos
		end.position.y = line2d.points[1].y + (end.frames.get_frame(end.animation, end.frame).get_height() / 2)
		
	end.flip_v = downScroll

func refreshAnim():
	spr.play(direction)
		
func rotateImage():
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
