extends Node2D

func _ready() -> void:
	var prog := get_node_or_null("/root/Progression")
	if prog and prog.has_method("reset_run_coins"):
		prog.reset_run_coins()
