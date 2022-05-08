extends Stage

onready var anim = $bg/parallax/anim
onready var PlayState:Node2D = $"../"

var lightningStrikeBeat = 0
var lightningOffset = 0

onready var thunder = [
	$thunder_1,
	$thunder_2,
]

func _ready():
	Conductor.connect("beat_hit", self, "beat_hit")
	#Conductor.connect("step_hit", self, "step_hit")
	
func beat_hit():
	if not PlayState.countdown_active:
		randomize()
		if randi()%11 == 10 and Conductor.cur_beat > lightningStrikeBeat + lightningOffset:
			lightningStrikeBeat = Conductor.cur_beat
			lightningOffset = randi()%24
			
			thunder[randi()%2].play(0)
			anim.play("strike")
			
			PlayState.gf.play_anim("scared")
			PlayState.gf.special_anim = true
			
			PlayState.bf.play_anim("scared")

func _on_spr_animation_finished():
	anim.play("idle")
