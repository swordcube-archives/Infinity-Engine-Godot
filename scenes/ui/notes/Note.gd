extends Node2D

class_name Note

var downScroll:bool = false

onready var spr:AnimatedSprite = $spr
onready var end:Sprite = $end
onready var line2d:Line2D = $Line2D

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
		
	end.texture = load(PlayStateSettings.currentUiSkin.sustain_tex_path+"/"+direction+" tail.png")
		
	match Preferences.getOption("clip-style"):
		"StepMania":
			line2d.z_index = -1
			end.z_index = -1
			
	line2d.texture = load(PlayStateSettings.currentUiSkin.sustain_tex_path+"/"+direction+" hold.png")
	line2d.width = end.texture.get_width()*PlayStateSettings.currentUiSkin.note_scale
	#line2d.scale.y = PlayStateSettings.currentUiSkin.note_scale
	
	end.modulate.a = 0.6
		
	var ss = PlayStateSettings.currentUiSkin.note_scale
	spr.scale = Vector2(ss, ss)
	end.scale = spr.scale
		
	refreshAnim()
	
	line2d.position.y = 0
	
func _process(delta):
	var yPos:float = ((sustainLength / 1.5) * PlayStateSettings.scrollSpeed) #/ spr.scale.y#*PlayStateSettings.currentUiSkin.note_scale
	var endHeight:float = end.texture.get_height()
	var fortnite:float = (endHeight*PlayStateSettings.currentUiSkin.note_scale)
	if downScroll:
		line2d.points[1].y = -yPos
		end.position.y = line2d.points[1].y - (fortnite / 2)
	else:
		line2d.points[1].y = yPos
		end.position.y = line2d.points[1].y + (fortnite / 2)
		
	end.flip_v = downScroll

func refreshAnim():
	spr.play(direction)
