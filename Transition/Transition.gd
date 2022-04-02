extends Node2D

var saved_scene = ""
export(float) var duration = 0.55

func _fade_in():
	visible = true
	var tween = Tween.new()
	tween.interpolate_property(self, "position", Vector2(0, -1200), Vector2(0, 0), duration)
	add_child(tween)
	tween.start()
	tween.connect("tween_all_completed", self, "_fade_out")

func transition_to_scene(scene):
	saved_scene = scene
	_fade_in()

func _fade_out():
	SceneManager.switch_scene(saved_scene)
	visible = true
	var tween = Tween.new()
	tween.interpolate_property(self, "position", self.position, Vector2(0, 1200), duration)
	add_child(tween)
	tween.start()
