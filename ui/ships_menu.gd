extends Control

@export var ships: Array[ShipInfo] = []                         # Assigne Starter.tres puis Falcon.tres (par ex.)
@export var back_scene_path: String = "res://content/ui/levels_menu.tscn"

@onready var _coins: Label = $VBox/Coins
@onready var _list: VBoxContainer = $VBox/List
@onready var _btn_back: Button = $VBox/BtnBack

func _ready() -> void:
	# Bouton "Back"
	if _btn_back and not _btn_back.is_connected("pressed", Callable(self, "_on_back")):
		_btn_back.pressed.connect(Callable(self, "_on_back"))

	# Écoute Progression (coins / achats / sélection)
	var prog: Node = get_node_or_null("/root/Progression")
	if prog:
		if not prog.is_connected("coins_changed", Callable(self, "_on_coins_changed")):
			prog.connect("coins_changed", Callable(self, "_on_coins_changed"))
		if not prog.is_connected("ships_changed", Callable(self, "_rebuild")):
			prog.connect("ships_changed", Callable(self, "_rebuild"))
		if not prog.is_connected("selected_ship_changed", Callable(self, "_rebuild")):
			prog.connect("selected_ship_changed", Callable(self, "_rebuild"))

	_update_coins_label()
	_rebuild()

# ---------- NAV ----------

func _on_back() -> void:
	if ResourceLoader.exists(back_scene_path):
		get_tree().change_scene_to_file(back_scene_path)
	else:
		push_error("ShipsMenu: back_scene_path introuvable: " + back_scene_path)

# ---------- COINS UI ----------

func _on_coins_changed(_run: int, _total: int) -> void:
	_update_coins_label()

func _update_coins_label() -> void:
	var prog: Node = get_node_or_null("/root/Progression")
	var total: int = 0
	if prog and "coins_total" in prog:
		total = int(prog.coins_total)
	_coins.text = "Coins: %d" % total

# ---------- BUILD LIST ----------

func _rebuild() -> void:
	_clear_list()
	var prog: Node = get_node_or_null("/root/Progression")
	for s in ships:
		var card: Control = _make_ship_card(s, prog)
		_list.add_child(card)

func _clear_list() -> void:
	for c in _list.get_children():
		c.queue_free()

func _make_ship_card(info: ShipInfo, prog: Node) -> Control:
	var card := HBoxContainer.new()
	card.add_theme_constant_override("separation", 12)

	# Thumbnail (optionnel)
	if info.thumbnail:
		var img := TextureRect.new()
		img.texture = info.thumbnail
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img.custom_minimum_size = Vector2(64, 48)
		card.add_child(img)

	# Textes
	var vb := VBoxContainer.new()
	var title := Label.new()
	title.text = info.title
	title.add_theme_font_size_override("font_size", 20)

	var desc := Label.new()
	desc.text = info.description
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	vb.add_child(title)
	vb.add_child(desc)
	card.add_child(vb)

	# Colonne droite (prix + bouton)
	var right := VBoxContainer.new()
	right.alignment = BoxContainer.ALIGNMENT_CENTER
	var price := Label.new()
	price.text = "Cost: %d" % info.cost
	right.add_child(price)

	var btn := Button.new()
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	right.add_child(btn)
	card.add_child(right)

	# État selon progression
	var owned: bool = false
	var selected: bool = false
	if prog:
		if prog.has_method("is_ship_owned"):
			owned = bool(prog.is_ship_owned(info.id))
		if "selected_ship" in prog:
			selected = (StringName(prog.selected_ship) == info.id)

	if owned:
		if selected:
			btn.text = "Selected"
			btn.disabled = true
		else:
			btn.text = "Select"
			btn.disabled = false
			btn.pressed.connect(Callable(self, "_on_select_pressed").bind(info.id))
	else:
		btn.text = "Buy"
		var affordable: bool = false
		if prog and prog.has_method("can_afford"):
			affordable = bool(prog.can_afford(info.cost))
		btn.disabled = not affordable
		btn.pressed.connect(Callable(self, "_on_buy_pressed").bind(info.id, info.cost))

	return card

# ---------- ACTIONS ----------

func _on_buy_pressed(id: StringName, cost: int) -> void:
	var prog: Node = get_node_or_null("/root/Progression")
	if not prog:
		return
	var ok: bool = false
	if prog.has_method("buy_ship"):
		ok = bool(prog.buy_ship(id, cost))
	if ok and prog.has_method("select_ship"):
		prog.select_ship(id)
	_update_coins_label()
	_rebuild()

func _on_select_pressed(id: StringName) -> void:
	var prog: Node = get_node_or_null("/root/Progression")
	if prog and prog.has_method("select_ship"):
		if prog.select_ship(id):
			_rebuild()
