extends Area2D
class_name MoneyPickup

@export var speed_down: float = 140.0
@export var value: int = 1
@export var lifetime: float = 6.0

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D
var _t: float = 0.0

func _ready() -> void:
	# évite de changer l’état physique pendant le flush
	monitoring = false
	set_deferred("monitoring", true)

	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		connect("area_entered", Callable(self, "_on_area_entered"))

	if _anim and _anim.sprite_frames:
		_anim.play()

func _physics_process(dt: float) -> void:
	# Descente simple
	global_position.y += speed_down * dt

	# Timer / hors écran bas
	_t += dt
	var rect: Rect2 = get_viewport().get_visible_rect()
	if _t >= lifetime or global_position.y > rect.end.y + 48.0:
		queue_free()

func _on_area_entered(a: Area2D) -> void:
	# On valide que l'Area appartient au Player (group "player")
	var owner_node: Node = a.get_parent()
	if owner_node and owner_node.is_in_group("player"):
		var prog := get_node_or_null("/root/Progression")
		if prog and prog.has_method("add_coins"):
			prog.add_coins(value)
		queue_free()

func set_value(v: int) -> void:
	value = v
