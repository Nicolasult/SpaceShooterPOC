extends Node
class_name Stats

@export var base_max_hp: float = 100.0    # ← ancien "max_hp"
@export var damage: float = 10.0
@export var fire_rate: float = 6.0        # tirs/s
@export var move_speed: float = 200.0

@export var resistances := {
	"laser": 1.0,
	"enemy": 1.0,
	"player": 1.0
}

func damage_taken_mult_from(tags: Array) -> float:
	var mult: float = 1.0
	for t in tags:
		if resistances.has(t):
			mult *= float(resistances[t])
	return mult
