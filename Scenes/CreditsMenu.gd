extends Node2D

var json = null
var credits = {}

var pages = []

var selected_page = 0
var selected_credit = 0

var selected_social = 0

var upwards = 0

var bg_tween = Tween.new()

func _ready():
	if not AudioHandler.get_node("Inst").playing and not AudioHandler.get_node("Voices").playing and not AudioHandler.get_node("freakyMenu").playing:
		AudioHandler.play_audio("freakyMenu")
		
	json = JsonUtil.get_json(Paths.json("Data/Credits"))
	
	generate_credits()
	spawn_credits()
	
	change_selection(0)
	change_social(0)
	
func _process(delta):
	var index = 0
	for credit in $Credits.get_children():
		credit.global_position.y = lerp(credit.global_position.y, (112 + (152 * index)) - (152 * upwards), delta * 7)
		index += 1
		
	if Input.is_action_just_pressed("ui_back"):
		SceneManager.switch_scene("MainMenu")
		
	if Input.is_action_just_pressed("ui_up"):
		change_selection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		change_selection(1)

	if Input.is_action_just_pressed("ui_left"):
		change_social(-1)
		
	if Input.is_action_just_pressed("ui_right"):
		change_social(1)
		
	if Input.is_action_just_pressed("ui_accept"):
		var socials = credits[pages[selected_page]][selected_credit].socials
		var link = socials[socials.keys()[selected_social]]
		print("GOING TO LINK: " + link)
		OS.shell_open(link)
		
	upwards = round(selected_credit / 4) * 4
	
func change_social(amount):
	var socials = credits[pages[selected_page]][selected_credit].socials
	
	selected_social += amount
	if selected_social < 0:
		selected_social = len(socials) - 1
	if selected_social > len(socials) - 1:
		selected_social = 0
		
	$Credits.get_children()[selected_credit].get_node("Link").text = "< " + socials.keys()[selected_social] + " >"
		
func change_selection(amount):
	AudioHandler.play_audio("scrollMenu")
	
	selected_credit += amount
	if selected_credit < 0:
		selected_credit = len(credits[pages[selected_page]]) - 1
	if selected_credit > len(credits[pages[selected_page]]) - 1:
		selected_credit = 0
		
	selected_social = 0
	change_social(0)
		
	var index = 0
	for credit in $Credits.get_children():
		credit.modulate.a = 0.6
		
		if selected_credit == index:
			credit.modulate.a = 1
		
		index += 1
		
	bg_tween.interpolate_property($BG, "modulate", $BG.modulate, Color(credits[pages[selected_page]][selected_credit].color), 1)
	add_child(bg_tween)
	bg_tween.start()
	
func spawn_credits():
	for credit in $Credits.get_children():
		credit.queue_free()
		
	var index = 0
	for credit in credits[pages[selected_page]]:
		var newCredit = $CreditTemplate.duplicate()
		newCredit.visible = true
		newCredit.global_position.y = 112 + (60 * index)
		newCredit.get_node("Title").text = credit.name
		newCredit.get_node("Description").text = credit.description
		
		newCredit.texture = Paths.image("Credits/" + credit.icon)
	
		newCredit.get_node("Link").text = "< " + credit.socials.keys()[selected_social] + " >"
		$Credits.add_child(newCredit)
		
		index += 1
	
func generate_credits():
	for credit in json.credits:
		if not credit.page in credits:
			credits[credit.page] = []
			
		if not credit.page in pages:
			pages.append(credit.page)
			
		credits[credit.page].append({
			"name": credit.name,
			"icon": credit.icon, 
			"description": credit.description, 
			"color": credit.color, 
			"page": credit.page,
			"socials": credit.socials
		})
