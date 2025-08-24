extends Area2D

signal hit(amount: float, tags: Array)

@export var health: NodePath
@onready var _hp: Node = get_node_or_null(health)

func apply_damage(ev: DamageEvent) -> void:
	var mult := 1.0
	if has_node("/root/LevelManager"):
		var lm = get_node("/root/LevelManager")
		if lm.has_method("get_damage_taken_mult"):
			mult = lm.get_damage_taken_mult(self)

	var final := ev.amount * mult

	if _hp and _hp.has_method("apply"):
		_hp.apply(final)
		# n’émet le flash que si la cible survit
		if _hp.has_method("is_dead") and not _hp.is_dead():
			emit_signal("hit", final, ev.tags)
	else:
		push_error("Damageable: Health node not set or invalid on " + str(self))
