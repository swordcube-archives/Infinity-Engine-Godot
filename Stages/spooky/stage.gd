extends Node2D

func _ready():
	Conductor.connect("beat_hit", self, "beat_hit")
	#Conductor.connect("step_hit", self, "step_hit")
	
func beat_hit():
	if not get_node("../../").countdown_active:
		randomize()
		if randi()%11 == 10:
			AudioHandler.play_audio("thunder_" + str(randi()%2 + 1))
			$bg/parallax/spr.play("strike")
			
			var characters = get_node("../../Characters")
			characters.get_node("gf").play_anim("scared")
			characters.get_node("gf").special_anim = true

func _on_spr_animation_finished():
	$bg/parallax/spr.play("idle")
