extends Area2D

@export var amount: float = 10.0
@export var tags: Array[String] = ["laser", "player"]

func _on_area_entered(a: Area2D) -> void:
	if a.has_method("apply_damage"):
		var ev:= DamageEvent.new()
		ev.amount = amount
		ev.tags = tags
		a.apply_damage(ev)
	queue_free()
