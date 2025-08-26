extends Node
class_name RecycleY

@export var bottom_margin: float = 720.0   # Y sous laquelle on recycle
@export var top_y: float = -32.0           # Y de réapparition en haut (au-dessus de l’écran)

func _process(delta):
	var p := get_parent()
	if p and p is Node2D:
		if p.global_position.y > bottom_margin:
			p.global_position.y = top_y
