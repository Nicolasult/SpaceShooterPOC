class_name MoveStraight
extends Movement

@export var speed : float = 200.0
@export var dir : Vector2 = Vector2.DOWN

func velocity(_node, _dt): 
	return dir.normalized() * speed
