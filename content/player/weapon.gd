# Weapon.gd (version simple)
extends Node
@export var projectile_scene: PackedScene
@export var muzzle_offset: Vector2 = Vector2(0, -16)
@export var cooldown: float = 0.5
var _cd := 0.0

func auto_fire(dt: float) -> void:
	_cd -= dt
	if _cd <= 0.0:
		_fire_once()
		_cd = cooldown

func _fire_once() -> void:
	if projectile_scene == null:
		push_warning("Weapon: projectile_scene is null")
		return
	var p = projectile_scene.instantiate()
	p.global_position = get_parent().global_position + muzzle_offset
	get_tree().current_scene.add_child(p)
