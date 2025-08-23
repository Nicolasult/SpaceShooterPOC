extends Area2D

@export var health: NodePath

@onready var _hp: Node = get_node(health)

func apply_damage(ev: DamageEvent) -> void:
	var mult:= LevelManager.get_damage_taken_mult(self) if Engine.has_singleton("LevelManager") else 1.0
	_hp.apply(ev.amount * mult)
