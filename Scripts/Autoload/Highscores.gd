extends Node

# default save values
var og_save = {
	"week-scores": {},
	"song-scores": {},
}

var initialized = false

var save = {}

var save_file = File.new()

func _ready():
	if save_file.file_exists("user://Scores.json"):
		save_file.open("user://Scores.json", File.READ)
		save = JSON.parse(save_file.get_as_text()).result
	else:
		save_file.open("user://Scores.json", File.WRITE)
		save_file.store_line(to_json(og_save))
	
	for thing in og_save:
		if not thing in save:
			save[thing] = og_save[thing]
	
	save_file.close()
	initialized = true

func save_dict():
	return save

func get_week_score(week):
	if not week in save["week-scores"]:
		set_week_score(week, 0)
		
	return save["week-scores"][week]
	
func get_song_score(song):
	if not song in save["song-scores"]:
		set_song_score(song, 0)
		
	return save["song-scores"][song]

func set_week_score(week, value):
	save["week-scores"][week] = value
	
	save_file.open("user://Scores.json", File.WRITE)
	save_file.store_line(to_json(save))
	
	save_file.close()
	
func set_song_score(song, value):
	save["song-scores"][song] = value
	
	save_file.open("user://Scores.json", File.WRITE)
	save_file.store_line(to_json(save))
	
	save_file.close()
