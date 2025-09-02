extends Control

@export var levels: Array[LevelInfo] = []      # assigne tes 3 *.tres dans l’inspecteur

@onready var _box: VBoxContainer = $VBox/LevelsBox

func _ready() -> void:
	_build()
	$VBox/BtnBack.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/MainMenu.tscn"))

func _build() -> void:
	for c in _box.get_children():
		c.queue_free()
	for i in levels.size():
		var li: LevelInfo = levels[i]
		var b := Button.new()
		b.text = "%d. %s" % [i+1, li.title]
		b.disabled = not li.unlocked
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(_on_level_pressed.bind(i))
		_box.add_child(b)

func _on_level_pressed(index: int) -> void:
	if index < 0 or index >= levels.size(): return
	var li: LevelInfo = levels[index]
	if li == null or li.scene == null: return

	var prog := get_node_or_null("/root/Progression")
	if prog and prog.has_method("reset_run_coins"):
		prog.reset_run_coins()

	get_tree().change_scene_to_packed(li.scene)
