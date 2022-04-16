extends CanvasLayer

var achievement_list = []
var listing_shit = false

func _ready():
	$Node.visible = false

func _process(delta):
	$Node/Icon.scale.x = (400 / $Node/Icon.texture.get_width()) * 0.2
	$Node/Icon.scale.y = (400 / $Node/Icon.texture.get_height()) * 0.2
	
func unlock_achievements():
	print("UNLOCKING!!!!")
	
	var old_ach_list = achievement_list.duplicate()
	
	if not listing_shit:
		listing_shit = true
		if len(achievement_list) > 0:
			for achievement in old_ach_list:
				$Node.visible = true
				$Node.position.x = -444
	
				var ach = Achievements.achievements[achievement_list[0]] 
	
				AudioHandler.play_audio("confirmMenu")
				$Node/Icon.texture = ach.icon
				$Node/Title.text = ach.title
				$Node/Description.text = ach.description
				$Node/Tween.interpolate_property($Node, "position", $Node.position, Vector2(0, $Node.position.y), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
				$Node/Tween.start()
				
				achievement_list.remove(0)
				print(achievement_list)
				
				var timer = Timer.new()
				timer.set_wait_time(3)
				add_child(timer)
				timer.start()
				timer.set_one_shot(true)
				
				yield(timer, "timeout")
				$Node/Tween.interpolate_property($Node, "position", $Node.position, Vector2(-444, $Node.position.y), 1, Tween.TRANS_CUBIC, Tween.EASE_IN)
				$Node/Tween.start()
				
				var timer2 = Timer.new()
				timer2.set_wait_time(1)
				add_child(timer2)
				timer2.start()
				timer2.set_one_shot(true)
				
				yield(timer2, "timeout")
				if len(achievement_list) <= 0:
					listing_shit = false
					achievement_list.clear()
					print("WE DONE LISTING ACHIEVEMENTS!")
		else:
			listing_shit = false
