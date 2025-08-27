extends Area2D

@export var speed: float = 700.0
@export var lifetime: float = 2.0
@export var damage: float = 10.0
@export var tags: Array[String] = ["laser", "player"]

var _t: float = 0.0

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))

func _physics_process(delta: float) -> void:
	# Déplacement vers le haut
	global_position.y -= speed * delta

	# Timer de vie (sécurité)
	_t += delta
	if _t >= lifetime:
		queue_free()

	# Si sort du haut de l’écran → destroy
	var rect: Rect2 = get_viewport().get_visible_rect()
	if global_position.y < rect.position.y:
		queue_free()

func _on_area_entered(a: Area2D) -> void:
	if a.has_method("apply_damage"):
		var ev := DamageEvent.new()
		ev.amount = damage
		ev.tags = tags
		a.apply_damage(ev)
	queue_free()

func set_damage(v: float) -> void:
	damage = v
