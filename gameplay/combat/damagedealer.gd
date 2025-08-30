extends Area2D
class_name DamageDealer

@export var amount: float = 10.0
@export var tags: Array[String] = ["enemy", "contact"]
@export var kill_self_on_hit: bool = true          # <- nouveauté
@export var health_node_path: NodePath = ^"../Health"

var _consumed: bool = false

func _ready() -> void:
	monitoring = true
	monitorable = true
	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(a: Area2D) -> void:
	if _consumed:
		return
	if not (a and a.has_method("apply_damage")):
		return

	# 1) Inflige UN SEUL tic de dégâts au joueur
	var ev := DamageEvent.new()
	ev.amount = amount
	ev.tags = tags
	a.apply_damage(ev)

	# 2) Marque comme consommé et coupe le contact
	_consumed = true
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	# 3) Détruire l’ennemi
	if kill_self_on_hit:
		_kill_self()

func _kill_self() -> void:
	var hp: Node = null
	if health_node_path != NodePath():
		hp = get_node_or_null(health_node_path)

	if hp and hp.has_method("apply") and hp.has_method("max_hp"):
		# Inflige le reste des PV pour déclencher "died"
		hp.apply(hp.max_hp)
	else:
		# Fallback : destruction directe du parent
		var root: Node = get_parent()
		if root:
			root.call_deferred("queue_free")
