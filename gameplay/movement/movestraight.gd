extends Movement

@export var speed : float = 200.0
@export var dir : Vector2 = Vector2.DOWN

func velocity(node, dt): 
	return dir.normalized() * speed
