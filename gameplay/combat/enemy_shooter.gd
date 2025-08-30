extends Node
class_name EnemyShooter

@export var projectile_scene: PackedScene
@export var muzzle_offset: Vector2 = Vector2(0, 12)    # un peu sous l’ennemi
@export var cooldown: float = 0.6
@export var only_when_side_phase: bool = true          # ← clé de ta demande
@export var damage_override: float = -1.0              # <0 = garder valeur par défaut du projectile

var _cd: float = 0.0
var _owner_2d: Node2D
var _movement: Object

func _ready() -> void:
	_owner_2d = get_parent() as Node2D
	# Récupère la propriété "movement" si elle existe sur le parent (Enemy)
	if _owner_2d and _owner_2d.has_method("get"):
		if _owner_2d.has_meta("movement"):
			_movement = _owner_2d.get_meta("movement")
		elif _owner_2d.has_method("get"):
			# fallback: lis la propriété exportée s'il y en a une
			if _owner_2d.has_method("get"):
				# Godot n'a pas de get_property dynamique, on tente via "has" sur la property list
				var plist = _owner_2d.get_property_list()
				for p in plist:
					if p is Dictionary and p.get("name","") == "movement":
						_movement = _owner_2d.get("movement")
						break
	# Si movement est une Resource avec signal, branche (facultatif)
	if _movement and _movement.has_signal("phase_changed"):
		_movement.connect("phase_changed", Callable(self, "_on_phase_changed"))

func _process(dt: float) -> void:
	_cd -= dt
	if _cd > 0.0:
		return
	if not projectile_scene:
		return

	# Condition de tir : soit pas de contrainte, soit "phase horizontale" requise
	if only_when_side_phase and _movement and _movement.has_method("is_side_phase"):
		if not _movement.is_side_phase():
			return

	_fire_once()
	_cd = cooldown

func _fire_once() -> void:
	var p: Node = projectile_scene.instantiate()
	if not p:
		return
	if _owner_2d:
		(p as Node2D).global_position = _owner_2d.global_position + muzzle_offset
	# override dégâts si demandé
	if damage_override >= 0.0:
		if p.has_method("set_damage"):
			p.call("set_damage", damage_override)
		elif _has_property(p, &"damage"):
			p.set("damage", damage_override)

	get_tree().current_scene.add_child(p)

func _on_phase_changed(_new_phase: int) -> void:
	# Petit bonus: reset le cooldown quand on ENTRE en phase horizontale (tir "immédiat").
	if only_when_side_phase and _movement and _movement.has_method("is_side_phase"):
		if _movement.is_side_phase():
			_cd = 0.0

func _has_property(obj: Object, prop: StringName) -> bool:
	for d in obj.get_property_list():
		if d is Dictionary and d.get("name","") == String(prop):
			return true
	return false
