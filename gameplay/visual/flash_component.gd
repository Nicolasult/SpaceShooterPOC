# res://gameplay/visual/flash_component.gd
extends Node
class_name FlashComponent

@export var target_path: NodePath                    # CanvasItem: Sprite2D / AnimatedSprite2D
@export var damageable_path: NodePath                # Area2D avec Damageable.gd (ex: "../Hitbox")
@export var flash_color: Color = Color(1, 1, 1, 1)   # blanc vif
@export var back_color: Color = Color(1, 1, 1, 1)    # couleur de base (1,1,1) = normal
@export var in_duration: float = 0.05                # montée éclair
@export var out_duration: float = 0.12               # retour progressif
@export var interrupt_prev: bool = true              # coupe un flash en cours si nouveau hit

var _target: CanvasItem
var _damageable: Node
var _tween: Tween

func _ready() -> void:
	_target = get_node_or_null(target_path)
	if _target == null:
		# Fallback: cherche un CanvasItem enfant
		_target = _find_first_canvas_item(get_parent())
	# Tente de récupérer le Damageable
	_damageable = get_node_or_null(damageable_path)
	if _damageable == null:
		_damageable = _find_first_damageable(get_parent())
	# Connecte le signal "hit"
	if _damageable and _damageable.has_signal("hit"):
		_damageable.connect("hit", Callable(self, "_on_hit"))

func _on_hit(amount: float, tags: Array) -> void:
	if _target == null:
		return
	if interrupt_prev and _tween and _tween.is_valid():
		_tween.kill()

	# Set flash immediately
	_target.modulate = flash_color

	# Tween back to normal
	_tween = get_tree().create_tween()
	_tween.tween_property(_target, "modulate", flash_color, in_duration) # petite “pause” au pic
	_tween.tween_property(_target, "modulate", back_color, out_duration)

func _find_first_canvas_item(root: Node) -> CanvasItem:
	if root is CanvasItem:
		return root
	for c in root.get_children():
		var found := _find_first_canvas_item(c)
		if found:
			return found
	return null

func _find_first_damageable(root: Node) -> Node:
	if root is Area2D and root.has_method("apply_damage") and root.has_signal("hit"):
		return root
	for c in root.get_children():
		var found := _find_first_damageable(c)
		if found:
			return found
	return null
