extends Node2D

# --- Flow / overlay / retour liste niveaux ---
@export var spawner_path: NodePath = ^"Spawner"
@export var overlay_path: NodePath = ^"LevelEndOverlay"
@export var levels_menu_path: String = "res://content/ui/levels_menu.tscn"
@export var show_delay_sec: float = 2.0
@export var pause_on_end: bool = false

# --- Spawn du vaisseau sélectionné ---
@export var player_spawn_path: NodePath = ^"PlayerSpawn"      # place un Marker2D (ou Node2D) dans la scène
@export var ships_catalog: Array[ShipInfo] = []               # assigne Starter.tres + Falcon.tres (ou plus)

var _spawner: Node = null
var _overlay: Node = null

func _ready() -> void:
	# 1) Reset monnaie du run
	var prog: Node = get_node_or_null("/root/Progression")
	if prog and prog.has_method("reset_run_coins"):
		prog.reset_run_coins()

	# 2) Références UI / flow
	_spawner = get_node_or_null(spawner_path)
	_overlay = get_node_or_null(overlay_path)

	if _overlay and _overlay.has_method("hide_now"):
		_overlay.hide_now()
	elif _overlay:
		_overlay.visible = false

	if _spawner and not _spawner.is_connected("level_cleared", Callable(self, "_on_level_cleared")):
		_spawner.connect("level_cleared", Callable(self, "_on_level_cleared"))

	# 3) Spawn du vaisseau sélectionné
	_spawn_selected_player()

func _on_level_cleared() -> void:
	if pause_on_end:
		get_tree().paused = true

	if _overlay and _overlay.has_method("show_message"):
		_overlay.show_message("Congratulations!", "Returning to Level Selection…")
	elif _overlay:
		_overlay.visible = true

	var t: Tween = create_tween()
	t.tween_interval(show_delay_sec)
	t.finished.connect(_go_back_to_levels)

func _go_back_to_levels() -> void:
	if pause_on_end:
		get_tree().paused = false
	get_tree().change_scene_to_file(levels_menu_path)

# -------------------------------
#        SPAWN DU VAISSEAU
# -------------------------------

func _spawn_selected_player() -> void:
	var spawn: Node2D = get_node_or_null(player_spawn_path) as Node2D
	if spawn == null:
		push_warning("Level: PlayerSpawn introuvable (node path: %s)" % [String(player_spawn_path)])
		return

	var prog: Node = get_node_or_null("/root/Progression")
	var chosen: ShipInfo = null
	if prog and "selected_ship" in prog:
		chosen = _shipinfo_by_id(StringName(prog.selected_ship))

	# Fallback: premier de la liste
	if chosen == null or chosen.scene == null:
		if ships_catalog.size() > 0:
			chosen = ships_catalog[0]
		if chosen == null or chosen.scene == null:
			push_error("Level: aucun ShipInfo/scene valide pour instancier le Player")
			return

	var player: Node2D = chosen.scene.instantiate() as Node2D
	player.global_position = spawn.global_position
	get_tree().current_scene.add_child(player)

func _shipinfo_by_id(id: StringName) -> ShipInfo:
	for s in ships_catalog:
		if s and s.id == id:
			return s
	return null
