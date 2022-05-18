extends Node2D

var SONG = GameplaySettings.SONG
var songData = GameplaySettings.SONG.song

onready var grid = $Grid
onready var notes = $Notes

onready var iconp2 = $Grid/Player2
onready var iconp1 = $Grid/Player1

var selected_section:int = 0

var current_note:Array

func _ready():
	notes.position = grid.position
	
	Conductor.change_bpm(float(songData["bpm"]))
	Conductor.song_position = 0.0
	
	AudioHandler.stop_music()
	load_section()
	
	iconp2.texture = CoolUtil.load_texture(Paths.char_icon(songData.player2))
	iconp1.texture = CoolUtil.load_texture(Paths.char_icon(songData.player1))

func _process(delta):
	grid.mouse_pos = get_global_mouse_position()
	grid.mouse_pos.x -= grid.global_position.x
	grid.mouse_pos.y -= grid.global_position.y
	
	grid.selected_x = floor(grid.mouse_pos.x / grid.grid_size)
	grid.selected_y = floor(grid.mouse_pos.y / grid.grid_size)
	
	if Input.is_action_just_pressed("ui_back"):
		SceneHandler.switch_to("ToolsMenu")
		
	if Input.is_action_just_pressed("ui_confirm"):
		SceneHandler.switch_to("PlayState")
		
	var cool_grid = grid.grid_size / (grid.note_snap / 16.0)
	
	if Input.is_action_just_pressed("ui_shift"):
		grid.square.rect_position = Vector2(grid.selected_x * grid.grid_size, grid.mouse_pos.y)
	else:
		grid.square.rect_position = Vector2(grid.selected_x * grid.grid_size, floor(grid.mouse_pos.y / cool_grid) * cool_grid)
		
	# lmao i'm sorry for this messy ass code
	if grid.square.rect_position.x < 0 \
	or grid.square.rect_position.y < 0 \
	or grid.square.rect_position.x > (grid.columns * grid.grid_size) \
	or grid.square.rect_position.y > ((grid.rows - 1) * grid.grid_size):
		grid.square.visible = false
	else:
		grid.square.visible = true
		
# nice functions, can i have them?
func y_to_time(y):
	return range_lerp(y + grid.grid_size, 0, 0 + (grid.rows * grid.grid_size), 0, 16 * Conductor.step_crochet)
	
func time_to_y(time):
	return range_lerp(time - Conductor.step_crochet, 0, 16 * Conductor.step_crochet, 0, 0 + (grid.rows * grid.grid_size))
	
func load_section():
	for note in songData.notes[selected_section].sectionNotes:
		var new_note = load("res://Scenes/Notes/Default/Note.tscn").instance()
		new_note.position.x = (note[1] + 1) * grid.grid_size
		new_note.position.y = time_to_y(note[0])
		new_note.charter_note = true
		notes.add_child(new_note)
		
		var anim_spr = new_note.spr
		anim_spr.offset.x = grid.grid_size * 1.8
		anim_spr.offset.y = grid.grid_size * 1.8
		var scale:float = grid.grid_size / anim_spr.frames.get_frame(anim_spr.animation, anim_spr.frame).get_height()
		new_note.scale = Vector2(scale, scale)
