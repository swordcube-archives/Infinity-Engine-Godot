extends Node

onready var inst:AudioStreamPlayer = $Song/Inst
onready var voices:AudioStreamPlayer = $Song/Voices

func playSFX(a:String, pos:float = 0.0):
	var node = get_node("SFX/" + a)
	if node:
		var clone = node.duplicate()
		clone.isClone = true
		clone.play()
		get_tree().current_scene.add_child(clone)
		
func playMusic(music:String, force:bool = false):
	inst.stop()
	voices.stop()
	
	var node = get_node("Music/" + music)
	for coolNode in $Music.get_children():
		if coolNode != node:
			coolNode.stop()
	
	if node:
		if not node.playing or force:
			node.play()
		
func playInst(song:String):
	for node in $Music.get_children():
		node.stop()
		
	inst.stop()
	inst.stream = load(Paths.inst(song))
	inst.play()
	
func playVoices(song:String):
	voices.stop()
	voices.stream = load(Paths.voices(song))
	voices.play()
