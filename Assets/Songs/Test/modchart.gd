extends Modchart

onready var sprite = $DVD
onready var label = $Label

onready var shader = $"Funyn!!!"

onready var PlayState = $"../"

onready var dad = $"../".dad
onready var gf = $"../".gf
onready var bf = $"../".bf

onready var sound = $Soudnd

func _ready():
	PlayState.show_rating = false
	PlayState.show_combo = false
	
	Conductor.connect("beat_hit", self, "beat_hit")
	#Conductor.connect("step_hit", self, "step_hit")
	
var timer:int = 0

func _physics_process(delta):
	dad.position.y -= delta * 10
	bf.position.y -= delta * 10
	
	label.text = "CUR BEAT: " + str(Conductor.cur_beat)
	label.text += "\nCUR STEP: " + str(Conductor.cur_step)
	var value = sin(timer)
	sprite.scale.x = value * 1
	timer += delta * 90
	
	dad.rotation_degrees += 10
	gf.rotation_degrees += 10
	bf.rotation_degrees += 10
	
func beat_hit():
	if Conductor.cur_beat % 4 == 0:
		sound.play()
		
	shader.modulate = Color(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1), 1)
	shader.visible = !shader.visible
