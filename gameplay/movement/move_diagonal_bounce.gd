extends Movement
class_name MoveDiagonalBounce

@export var down_speed: float = 150.0        # vitesse verticale (vers le bas)
@export var side_speed: float = 120.0        # vitesse horizontale
@export var margin: float = 8.0              # marge de rebond depuis le bord de l'écran
@export var randomize_start_dir: bool = true # direction X aléatoire au 1er tick

var _dir_x: int = 1
var _inited: bool = false

func _init_start_dir() -> void:
	if _inited:
		return
	_inited = true
	if randomize_start_dir:
		# 50% gauche, 50% droite
		_dir_x = -1 if randf() < 0.5 else 1
	else:
		_dir_x = 1

func velocity(node: Node2D, dt: float) -> Vector2:
	_init_start_dir()

	# Rebond sur les bords de l'écran
	var rect: Rect2 = node.get_viewport().get_visible_rect()
	var left_limit: float = rect.position.x + margin
	var right_limit: float = rect.end.x - margin
	var x: float = node.global_position.x

	if x <= left_limit:
		_dir_x = 1
	elif x >= right_limit:
		_dir_x = -1

	return Vector2(_dir_x * side_speed, down_speed)
