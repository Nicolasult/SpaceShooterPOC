extends Node
class_name ScaleComponent

@export var target_path: NodePath            # Sprite2D / AnimatedSprite2D / Node2D
@export var base_scale: Vector2 = Vector2.ONE
@export var amplitude: float = 0.06          # 6% d'ampleur
@export var frequency: float = 2.0           # 2 oscillations/sec
@export var axis_mask: Vector2 = Vector2(1, 1) # (1,0) = X only ; (1,1) = XY
@export var randomize_phase: bool = true

var _t: float = 0.0
var _phase: float = 0.0
var _target: Node2D

func _ready() -> void:
	_target = get_node_or_null(target_path)
	if _target == null:
		# Fallback : si le parent est un Node2D, on l'utilise
		if get_parent() is Node2D:
			_target = get_parent()
	# phase aléatoire pour éviter la synchro parfaite de tous les ennemis
	if randomize_phase:
		_phase = randf() * TAU
	# applique l'échelle de base au démarrage
	if _target:
		_target.scale = base_scale

func _process(delta: float) -> void:
	if _target == null:
		return
	_t += delta
	var s: float = 1.0 + amplitude * sin((frequency * TAU) * _t + _phase)
	var sx: float = lerp(base_scale.x, base_scale.x * s, axis_mask.x)
	var sy: float = lerp(base_scale.y, base_scale.y * s, axis_mask.y)
	_target.scale = Vector2(sx, sy)
