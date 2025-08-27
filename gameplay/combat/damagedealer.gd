# res://gameplay/combat/damagedealer.gd
extends Area2D
class_name DamageDealer

@export var amount: float = 10.0
@export var tags: Array[String] = ["enemy", "contact"]
@export var cooldown: float = 0.35    # anti-spam sur contact prolongé

var _cd: float = 0.0

func _ready() -> void:
	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		connect("area_entered", Callable(self, "_on_area_entered"))

func _process(dt: float) -> void:
	if _cd > 0.0:
		_cd -= dt

func _on_area_entered(a: Area2D) -> void:
	if _cd > 0.0:
		return
	# Ne blesse que les Area2D capables de recevoir des dégâts (ex: Hitbox du joueur)
	if a and a.has_method("apply_damage"):
		var ev: DamageEvent = DamageEvent.new()
		ev.amount = amount
		ev.tags = tags
		a.apply_damage(ev)
		_cd = cooldown
