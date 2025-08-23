extends Node

signal died
signal changed(current, max)

@export var max_hp: float = 100.0

var hp: float = max_hp

func apply(amount: float):
	hp = clamp(hp - amount, 0.0, max_hp)
	emit_signal("changed", hp, max_hp)
	if hp <= 0.0: emit_signal("died")
