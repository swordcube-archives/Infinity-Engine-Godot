extends Stage

var gf = $"../".gf
var bf = $"../".bf

var lightningStrikeBeat = 0
var lightningOffset = 0

func _ready():
	Conductor.connect("beat_hit", self, "beat_hit")
	#Conductor.connect("step_hit", self, "step_hit")
	
func beat_hit():
	if not get_node("../../").countdown_active:
		randomize()
		if randi()%11 == 10 and Conductor.curBeat > lightningStrikeBeat + lightningOffset:
			lightningStrikeBeat = Conductor.curBeat
			lightningOffset = randi()%24
			
			AudioHandler.play_audio("thunder_" + str(randi()%2 + 1))
			$bg/parallax/spr.play("strike")
			
			gf.play_anim("scared")
			gf.special_anim = true
			
			bf.play_anim("scared")

func _on_spr_animation_finished():
	$bg/parallax/spr.play("idle")
