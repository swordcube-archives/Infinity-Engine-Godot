extends Node2D

var json = null

var dialogue_list:Array = []

var dialogue_timer = Timer.new()

var dialogue_array:Array = []

var dialogue_started:bool = false

func _ready():
	var song = Gameplay.SONG.song
	json = JsonUtil.get_json("res://Assets/Songs/" + song.song + "/dialogue")
	
	if json == null or not Gameplay.story_mode:
		end_dialogue()
	else:
		visible = true
		$box.visible = false

		dialogue_list = json["dialogue"]
		
		var tween = Tween.new()
		tween.interpolate_property($bg, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		add_child(tween)
		tween.start()
		
		var timer = Timer.new()
		timer.set_wait_time(1)
		add_child(timer)
		timer.start()
		timer.set_one_shot(true)
		
		dialogue_timer.set_wait_time(0.05)
		add_child(dialogue_timer)
		dialogue_timer.start()
		
		yield(timer, "timeout")
		$box.visible = true
		$box.play("normal open")
	
	#print("DIALOGUE JSON")
	#print(json)

func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if just_pressed and event is InputEventKey and event.pressed:
		next_dialogue()
		
var ending_dialogue:bool = false
		
func next_dialogue():
	if dialogue_started and not ending_dialogue:
		AudioHandler.play_audio("clickText")
		
		dialogue_list.remove(0)
		
		if len(dialogue_list) < 1:
			end_anims()
		else:
			render_dialogue()
		
func render_dialogue():
	$text.text = ""
	
	remove_child(dialogue_timer)
	dialogue_timer = Timer.new()
	dialogue_timer.set_wait_time(dialogue_list[0].speed)
	add_child(dialogue_timer)
	dialogue_timer.start()
	#$text.percent_visible = 0
	dialogue_array = []
	
	for i in len(dialogue_list[0].text):
		if not ending_dialogue:
			yield(dialogue_timer, "timeout")
			AudioHandler.play_audio("pixelText")
		
			if len(dialogue_list) > 0:
				dialogue_array.append(dialogue_list[0].text[i])
				$text.text += dialogue_array[i]
			else:
				end_anims()
			
var end_tween = Tween.new()
			
func end_anims():
	ending_dialogue = true
	
	$text.visible = false
	$box.play($box.animation.split(" idle")[0] + " open", true)
	
	end_tween.interpolate_property($bg, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	add_child(end_tween)
	end_tween.start()
	
func _process(delta):
	yield(end_tween, "tween_completed")
	end_dialogue()

func end_dialogue():
	get_node("../../").in_cutscene = false
	queue_free()

func _on_box_animation_finished():
	if "open" in $box.animation and not dialogue_started:
		dialogue_started = true
		
		$box.play($box.animation.split(" open")[0] + " idle")
		
		$text.visible = true
		render_dialogue()
		
	if "open" in $box.animation and dialogue_started:
		$box.visible = false
