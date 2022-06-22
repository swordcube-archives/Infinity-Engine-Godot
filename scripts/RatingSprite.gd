extends Sprite

export(bool) var moving:bool = true

var completedMovement:bool = false

export(float) var startVelocity:float = 5
export(float) var gravity:float = 10

var velocity:float = 0

func _ready():
	velocity = startVelocity
	
func _physics_process(delta):
	if moving:
		position.y += velocity
		velocity += gravity
