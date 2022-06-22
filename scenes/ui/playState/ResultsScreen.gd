extends Node2D

var ratingTextures:Dictionary = {
	"S+": preload("res://assets/images/ui/resultsScreen/S+.png"),
	"S": preload("res://assets/images/ui/resultsScreen/S.png"),
	"A": preload("res://assets/images/ui/resultsScreen/A.png"),
	"B": preload("res://assets/images/ui/resultsScreen/B.png"),
	"C": preload("res://assets/images/ui/resultsScreen/C.png"),
	"D": preload("res://assets/images/ui/resultsScreen/D.png"),
	"E": preload("res://assets/images/ui/resultsScreen/E.png"),
	"F": preload("res://assets/images/ui/resultsScreen/F.png"),
}

onready var texts:Dictionary = {
	"score": $Score,
	"accuracy": $Accuracy,
	"marvelous": $Marvelous,
	"sicks": $Sicks,
	"goods": $Goods,
	"bads": $Bads,
	"shits": $Shits,
	"misses": $Misses,
	"songName": $SongName,
}

var score:int = 0
var accuracy:float = 0.0

var marv:int = 0
var sicks:int = 0
var goods:int = 0
var bads:int = 0
var shits:int = 0
var misses:int = 0

onready var rating = $Rating

onready var PlayState = $"../../"

var tween = Tween.new()

func _ready():
	rating.texture = load("res://assets/images/ui/resultsScreen/" + Ranking.getRank(MathUtil.roundDecimal(PlayState.songAccuracy * 100, 2)) + ".png")
	texts["score"].text = "Score: " + str(score)
	texts["accuracy"].text = "Accuracy: " + str(accuracy) + "%"
	texts["marvelous"].text = "Marvelous: " + str(marv) 
	texts["sicks"].text = "Sicks: " + str(sicks)
	texts["goods"].text = "Goods: " + str(goods)
	texts["bads"].text = "Bads: " + str(bads)
	texts["shits"].text = "Shits: " + str(shits)
	texts["misses"].text = "Misses: " + str(misses)
	texts["songName"].text = PlayState.SONG.song + " - " + PlayStateSettings.difficulty.to_upper()
	add_child(tween)
	rating.modulate.a = 0
	var i:int = 0
	for key in texts.keys():
		texts[key].modulate.a = 0
		texts[key].rect_position.x -= 10
		tween.interpolate_property(texts[key], "rect_position:x", texts[key].rect_position.x, texts[key].rect_position.x + 10, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT, i*0.2)
		tween.interpolate_property(texts[key], "modulate:a", 0, 1, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT, i*0.2)
		i += 1
		
	tween.start()
	
	yield(get_tree().create_timer(1), "timeout")
	rating.scale = Vector2(1.5, 1.5)
	AudioHandler.playSFX("confirmMenu")
	tween.interpolate_property(rating, "scale", rating.scale, Vector2.ONE, 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.interpolate_property(rating, "modulate:a", 0, 1, 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	
func _process(delta):
	if Input.is_key_pressed(KEY_ENTER):
		PlayState.actuallyEndSong()
		queue_free()
