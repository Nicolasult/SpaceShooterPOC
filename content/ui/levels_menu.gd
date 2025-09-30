extends Control

@export var levels: Array[LevelInfo] = []   # tes 3 LevelInfo.tres

@onready var _box: VBoxContainer = $VBox/LevelsBox
@onready var _btn_back: Button = $VBox/BtnBack

func _ready() -> void:
	# Bouton "Back"
	if _btn_back and not _btn_back.is_connected("pressed", Callable(self, "_on_back")):
		_btn_back.pressed.connect(Callable(self, "_on_back"))

	# Écoute les changements de progression (déblocage)
	var prog: Node = get_node_or_null("/root/Progression")
	if prog and not prog.is_connected("levels_unlocked_changed", Callable(self, "_on_levels_unlocked_changed")):
		prog.connect("levels_unlocked_changed", Callable(self, "_on_levels_unlocked_changed"))

	_build()

func _on_back() -> void:
	get_tree().change_scene_to_file("res://content/ui/main_menu.tscn")

func _build() -> void:
	# Nettoyage
	for c in _box.get_children():
		c.queue_free()

	var prog: Node = get_node_or_null("/root/Progression")

	for i in levels.size():
		var li: LevelInfo = levels[i]
		var btn := Button.new()
		btn.text = "%d. %s" % [i + 1, li.title]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# On ignore li.unlocked et on s'aligne sur Progression
		var unlocked: bool = true
		if prog and prog.has_method("is_level_unlocked"):
			unlocked = prog.call("is_level_unlocked", i)

		btn.disabled = not unlocked

		# (Optionnel) style grisé clair si verrouillé
		if not unlocked:
			btn.add_theme_color_override("font_disabled_color", Color(0.7, 0.7, 0.7))

		# Lancer le niveau i
		btn.pressed.connect(Callable(self, "_on_level_pressed").bind(i))
		_box.add_child(btn)

func _on_level_pressed(index: int) -> void:
	if index < 0 or index >= levels.size():
		return
	var li: LevelInfo = levels[index]
	if li == null or li.scene == null:
		return

	# Reset monnaie du run
	var prog: Node = get_node_or_null("/root/Progression")
	if prog and prog.has_method("reset_run_coins"):
		prog.call("reset_run_coins")

	get_tree().change_scene_to_packed(li.scene)

func _on_levels_unlocked_changed(_unlocked_max: int) -> void:
	# Quand un niveau se débloque (fin de level), on reconstruit la liste
	_build()
