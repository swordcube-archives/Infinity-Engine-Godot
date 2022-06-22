extends Stage

onready var limoPeopleGuys:Array = [
	$ParallaxBackground/layer2/limoDancer,
	$ParallaxBackground/layer2/limoDancer2,
	$ParallaxBackground/layer2/limoDancer3,
	$ParallaxBackground/layer2/limoDancer4,
	$ParallaxBackground/layer2/limoDancer5,
]

func createPost():
	PlayState.gf.z_index = -1
	
func beatHit():
	for guy in limoPeopleGuys:
		guy.dance()
