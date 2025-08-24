extends Area2D

@export var health: NodePath

@onready var _hp: Node = get_node(health)

func apply_damage(ev: DamageEvent) -> void:
	var mult := 1.0
	if has_node("/root/LevelManager"):
		var lm = get_node("/root/LevelManager")
		if lm.has_method("get_damage_taken_mult"):
			mult = lm.get_damage_taken_mult(self)

	_hp.apply(ev.amount * mult)
