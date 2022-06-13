extends Node

onready var inst:AudioStreamPlayer = $Song/Inst
onready var voices:AudioStreamPlayer = $Song/Voices

func playSFX(a, pos:float = 0.0):
	var node = get_node("SFX/" + a)
	if node != null:
		var clone = node.duplicate()
		clone.isClone = true
		clone.play()
		get_tree().current_scene.add_child(clone)
		
func playInst(song):
	inst.stop()
	inst.stream = load(Paths.inst(song))
	inst.play()
	
func playVoices(song):
	voices.stop()
	voices.stream = load(Paths.voices(song))
	voices.play()
