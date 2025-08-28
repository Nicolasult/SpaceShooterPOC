extends Node

signal died
signal changed(current: float, max: float)

@export var max_hp: float = 100.0
@export var stats_path: NodePath        # ← assigne $Stats dans l’inspecteur

var hp: float

func _ready() -> void:
	# Si des Stats existent, on lit base_max_hp une fois au spawn
	if stats_path != NodePath():
		var stats := get_node_or_null(stats_path)
		if stats and _has_property(stats, &"base_max_hp"):
			max_hp = float(stats.get("base_max_hp"))
	hp = max_hp
	emit_signal("changed", hp, max_hp)

func apply(amount: float) -> void:
	hp = clamp(hp - amount, 0.0, max_hp)
	emit_signal("changed", hp, max_hp)
	if hp <= 0.0:
		emit_signal("died")

func heal(amount: float) -> void:
	hp = clamp(hp + amount, 0.0, max_hp)
	emit_signal("changed", hp, max_hp)

func set_max_hp(v: float, keep_ratio: bool = true) -> void:
	var ratio: float = hp / max_hp if max_hp > 0.0 else 1.0
	max_hp = max(1.0, v)
	hp = max_hp * ratio if keep_ratio else max_hp
	emit_signal("changed", hp, max_hp)

func is_dead() -> bool:
	return hp <= 0.0

func _has_property(obj: Object, prop: StringName) -> bool:
	for d in obj.get_property_list():
		if d is Dictionary and d.get("name","") == String(prop):
			return true
	return false
