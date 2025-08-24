extends Node
class_name Stats

# Bases
@export var max_hp: float = 100.0
@export var damage: float = 10.0
@export var fire_rate: float = 6.0   # tirs par seconde si tu l'utilises
@export var move_speed: float = 200.0

# Résistances/faiblesses par tag (ex: "laser", "explosion")
@export var resistances := {
	"laser": 1.0,
	"enemy": 1.0,
	"player": 1.0
}

func damage_taken_mult_from(tags: Array) -> float:
	var mult := 1.0
	for t in tags:
		if resistances.has(t):
			mult *= float(resistances[t])
	return mult
