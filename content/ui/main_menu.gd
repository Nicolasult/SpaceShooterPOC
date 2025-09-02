extends Control

@export var levels: Array[LevelInfo] = []   # assigne tes 3 *.tres dans l’inspecteur

@onready var _levels_box: VBoxContainer = $VBox/Levels
@onready var _title: Label = $VBox/Title

func _ready() -> void:
	_build_level_buttons()

func _build_level_buttons() -> void:
	# Nettoie au cas où (hot-reload)
	for c in _levels_box.get_children():
		c.queue_free()

	for i in levels.size():
		var info: LevelInfo = levels[i]
		var btn := Button.new()
		btn.text = "%d. %s" % [i + 1, info.title]
		btn.disabled = not info.unlocked
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_levels_box.add_child(btn)

		var cb: Callable = Callable(self, "_on_level_pressed")
		btn.pressed.connect(cb.bind(i))

func _on_level_pressed(index: int) -> void:
	if index < 0 or index >= levels.size():
		return
	var info: LevelInfo = levels[index]
	if info == null or info.scene == null:
		return

	# Remise à zéro de la monnaie du run si tu utilises Progression
	var prog := get_node_or_null("/root/Progression")
	if prog and prog.has_method("reset_run_coins"):
		prog.reset_run_coins()

	get_tree().change_scene_to_packed(info.scene)
