extends CanvasLayer

@export var health_path: NodePath        # assigne $Player/Health
@export var hide_on_death: bool = false  # option : masquer à 0 HP

@onready var _bar: ProgressBar = %Bar
@onready var _label: Label = %Label
@onready var _hp: Node = get_node_or_null(health_path)

func _ready() -> void:
	if _bar:
		_bar.min_value = 0.0
		_bar.max_value = 100.0
		_bar.value = 100.0

	if _hp and _hp.has_signal("changed"):
		_hp.connect("changed", Callable(self, "_on_hp_changed"))
	_init_from_health()

	if hide_on_death and _hp and _hp.has_signal("died"):
		_hp.connect("died", Callable(self, "_on_dead"))

func _init_from_health() -> void:
	if not _hp: return
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
