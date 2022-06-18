extends Stage

onready var upperBop = $ParallaxBackground/layer2/UpperBop
onready var bottomBop = $ParallaxBackground/layer5/BottomBop
onready var santa = $Santa

func beatHit():
	upperBop.frame = 0
	upperBop.play("Upper Crowd Bob")
	
	bottomBop.frame = 0
	bottomBop.play("Bottom Level Boppers")
	
	santa.frame = 0
	santa.play("santa idle in fear")
