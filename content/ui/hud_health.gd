extends CanvasLayer

@export var hide_on_death: bool = false

@onready var _bar: ProgressBar = $MarginContainer/Panel/VBoxContainer/Bar
@onready var _label: Label = $MarginContainer/Panel/VBoxContainer/HP

var _hp: Node = null
var _wired: bool = false   # évite "already connected" lors des hot-reloads

func _ready() -> void:
	# Init UI
	if _bar:
		_bar.min_value = 0.0
		_bar.max_value = 100.0
		_bar.value = 100.0
	if _label:
		_label.text = "HP 100 / 100"

	# Trouve le player par groupe (dans Player.gd: add_to_group("player"))
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_node("Health"):
		_hp = player.get_node("Health")

	# Connexions (une seule fois)
	if _hp and not _wired:
		if not _hp.is_connected("changed", Callable(self, "_on_hp_changed")):
			_hp.connect("changed", Callable(self, "_on_hp_changed"))
		if hide_on_death and _hp.has_signal("died") and not _hp.is_connected("died", Callable(self, "_on_dead")):
			_hp.connect("died", Callable(self, "_on_dead"))
		_wired = true

		# Init immédiate
		if "hp" in _hp and "max_hp" in _hp:
			_on_hp_changed(float(_hp.hp), float(_hp.max_hp))

func _on_hp_changed(current: float, max_value: float) -> void:
	if _bar:
		_bar.max_value = max_value
		_bar.value = current
	if _label:
		_label.text = "HP %d / %d" % [int(current), int(max_value)]

func _on_dead() -> void:
	if hide_on_death:
		visible = false

func _exit_tree() -> void:
	_wired = false
