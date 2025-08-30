extends Movement
class_name MoveStaircase

@export var down_speed: float = 150.0        # vitesse verticale pendant la phase "bas"
@export var side_speed: float = 120.0        # vitesse horizontale pendant la phase "côté"
@export var vertical_time: float = 0.40      # durée (s) d'une marche verticale
@export var horizontal_time: float = 0.35    # durée (s) d'une marche horizontale
@export var margin: float = 8.0              # marge avant rebond sur les bords
@export var randomize_start_dir: bool = true # direction X initiale aléatoire (pour la 1re phase "côté")

enum Phase { DOWN, SIDE }

var _phase: int = Phase.DOWN
var _t: float = 0.0
var _dir_x: int = 1
var _inited: bool = false

func _init_once() -> void:
	if _inited: return
	_inited = true
	_phase = Phase.DOWN
	if randomize_start_dir:
		_dir_x = -1 if randf() < 0.5 else 1
	else:
		_dir_x = 1

func velocity(node: Node2D, dt: float) -> Vector2:
	_init_once()
	_t += dt

	var v: Vector2 = Vector2.ZERO

	if _phase == Phase.DOWN:
		# Descente
		v = Vector2(0.0, down_speed)
		if _t >= vertical_time:
			_phase = Phase.SIDE
			_t = 0.0
	else:
		# Déplacement horizontal + rebond immédiat sur bords
		var rect: Rect2 = node.get_viewport().get_visible_rect()
		var left_limit: float = rect.position.x + margin
		var right_limit: float = rect.end.x - margin
		var x: float = node.global_position.x
		if x <= left_limit:
			_dir_x = 1
		elif x >= right_limit:
			_dir_x = -1

		v = Vector2(float(_dir_x) * side_speed, 0.0)
		if _t >= horizontal_time:
			_phase = Phase.DOWN
			_t = 0.0

	return v
