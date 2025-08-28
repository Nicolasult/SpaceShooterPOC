extends Area2D

@export var speed: float = 700.0
@export var lifetime: float = 2.0
@export var damage: float = 10.0
@export var tags: Array[String] = ["laser", "player"]
@export var enemy_mask: int = 0b0010    # <-- mets ici le bit/layer "Enemy" de ta Hitbox

var _t: float = 0.0

func set_damage(v: float) -> void:
	damage = v

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))

func _physics_process(dt: float) -> void:
	# 1) Balayage anti-tunneling
	var from: Vector2 = global_position
	var to: Vector2 = from + Vector2(0, -speed * dt)

	var params := PhysicsRayQueryParameters2D.create(from, to)
	params.collision_mask = enemy_mask
	var hit := get_world_2d().direct_space_state.intersect_ray(params)
	if hit:
		var n: Object = hit.get("collider")
		# Monte dans l'arbre jusqu'à trouver un Area2D/Node avec apply_damage
		var target := n as Node
		while target and not target.has_method("apply_damage"):
			target = target.get_parent()
		if target and target.has_method("apply_damage"):
			var ev := DamageEvent.new()
			ev.amount = damage
			ev.tags = tags
			target.apply_damage(ev)
			queue_free()
			return

	# 2) Déplacement si pas de hit
	global_position = to

	# 3) Durée de vie + sortie écran
	_t += dt
	if _t >= lifetime:
		queue_free()
		return

	var rect: Rect2 = get_viewport().get_visible_rect()
	if global_position.y < rect.position.y:
		queue_free()

func _on_area_entered(a: Area2D) -> void:
	# Restera utile si l'ennemi "entre" dans le laser à basse vitesse
	if a.has_method("apply_damage"):
		var ev := DamageEvent.new()
		ev.amount = damage
		ev.tags = tags
		a.apply_damage(ev)
		queue_free()
