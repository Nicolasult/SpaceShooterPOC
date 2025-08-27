extends Node

@export var projectile_scene: PackedScene
@export var muzzle_offset: Vector2 = Vector2(0, -16)
@export var cooldown: float = 0.5                    # sera écrasé si Stats.fire_rate est présent
@export var stats_path: NodePath                     # -> $Stats sur le Player

var _cd: float = 0.0
var _stats: Stats

func _ready() -> void:
	_stats = get_node_or_null(stats_path) as Stats
	# Si Stats existe, on déduit le cooldown depuis fire_rate (tirs/sec)
	if _stats:
		var fr: float = max(0.01, float(_stats.fire_rate))
		cooldown = 1.0 / fr

func auto_fire(dt: float) -> void:
	_cd -= dt
	if _cd <= 0.0:
		_fire_once()
		_cd = cooldown

func _fire_once() -> void:
	if projectile_scene == null:
		push_warning("Weapon: projectile_scene is null")
		return

	var p: Node = projectile_scene.instantiate()
	var origin := get_parent() as Node2D
	if origin:
		(p as Node2D).global_position = origin.global_position + muzzle_offset

	# dégâts depuis Stats
	var dmg: float = _stats.damage if _stats else 10.0
	if p.has_method("set_damage"):
		p.call("set_damage", dmg)
	elif _has_property(p, &"damage"):
		p.set("damage", dmg)

	get_tree().current_scene.add_child(p)

func _has_property(obj: Object, prop: StringName) -> bool:
	var plist: Array = obj.get_property_list()
	for d in plist:
		if d is Dictionary and d.get("name", "") == String(prop):
			return true
	return false
