extends Node2D

@export var spawner_path: NodePath = ^"Spawner"              # référence vers ton Spawner dans la scène
@export var overlay_path: NodePath = ^"LevelEndOverlay"      # instance de LevelEndOverlay.tscn dans la scène
@export var levels_menu_path: String = "res://content/ui/levels_menu.tscn"
@export var show_delay_sec: float = 2.0                      # durée d’affichage avant retour
@export var pause_on_end: bool = false                       # met le jeu en pause à la fin si true

var _spawner: Node = null
var _overlay: Node = null

func _ready() -> void:
	# Remise à zéro de l’or du run
	var prog := get_node_or_null("/root/Progression")
	if prog and prog.has_method("reset_run_coins"):
		prog.reset_run_coins()

	# Récupère les références
	_spawner = get_node_or_null(spawner_path)
	_overlay = get_node_or_null(overlay_path)

	# Cache l’overlay au départ (si script LevelEndOverlay fourni)
	if _overlay and _overlay.has_method("hide_now"):
		_overlay.hide_now()
	elif _overlay:
		_overlay.visible = false

	# Abonne-toi à la fin de level
	if _spawner and not _spawner.is_connected("level_cleared", Callable(self, "_on_level_cleared")):
		_spawner.connect("level_cleared", Callable(self, "_on_level_cleared"))

func _on_level_cleared() -> void:
	# Pause optionnelle
	if pause_on_end:
		get_tree().paused = true

	# Message de fin
	if _overlay and _overlay.has_method("show_message"):
		_overlay.show_message("Congratulations!", "Returning to Level Selection…")
	elif _overlay:
		_overlay.visible = true

	# Retour différé vers l’écran des niveaux
	var t := create_tween()
	t.tween_interval(show_delay_sec)
	t.finished.connect(_go_back_to_levels)

func _go_back_to_levels() -> void:
	if pause_on_end:
		get_tree().paused = false
	get_tree().change_scene_to_file(levels_menu_path)
