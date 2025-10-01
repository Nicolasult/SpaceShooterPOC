extends Control

@export var back_scene_path: String = "res://content/ui/main_menu.tscn"

@onready var _coins: Label       = $VBox/Coins
@onready var _life_info: Label   = $VBox/LifeRow/LifeInfo
@onready var _btn_life: Button   = $VBox/LifeRow/BtnLife
@onready var _dmg_info: Label    = $VBox/DamageRow/DamageInfo
@onready var _btn_dmg: Button    = $VBox/DamageRow/BtnDamage
@onready var _btn_back: Button   = $VBox/BtnBack

func _ready() -> void:
	_btn_back.pressed.connect(_on_back)
	_btn_life.pressed.connect(_on_buy_life)
	_btn_dmg.pressed.connect(_on_buy_damage)

	var prog := get_node_or_null("/root/Progression")
	if prog:
		if not prog.is_connected("coins_changed", Callable(self, "_on_coins_changed")):
			prog.connect("coins_changed", Callable(self, "_on_coins_changed"))
		if not prog.is_connected("upgrades_changed", Callable(self, "_rebuild")):
			prog.connect("upgrades_changed", Callable(self, "_rebuild"))

	_update_coins()
	_rebuild()

func _on_back() -> void:
	if ResourceLoader.exists(back_scene_path):
		get_tree().change_scene_to_file(back_scene_path)
	else:
		push_error("UpgradesMenu: back_scene_path introuvable: " + back_scene_path)

func _on_coins_changed(_run: int, _total: int) -> void:
	_update_coins()
	_rebuild() # pour maj des boutons grisés / non-grisés

func _update_coins() -> void:
	var prog := get_node_or_null("/root/Progression")
	var total: int = prog.coins_total if prog else 0
	_coins.text = "Coins: %d" % total

func _rebuild() -> void:
	var prog := get_node_or_null("/root/Progression")
	if prog == null:
		return

	# LIFE
	var life_lvl: int = prog.life_level
	var life_bonus: int = prog.get_life_bonus()
	var life_cost: int = prog.get_life_next_cost()
	_life_info.text = "Level %d (+%d HP) | Cost %d" % [life_lvl, life_bonus, life_cost]
	_btn_life.disabled = not prog.can_afford(life_cost)

	# DAMAGE
	var dmg_lvl: int = prog.damage_level
	var dmg_bonus: float = prog.get_damage_bonus()
	var dmg_cost: int = prog.get_damage_next_cost()
	_dmg_info.text = "Level %d (+%.0f dmg) | Cost %d" % [dmg_lvl, dmg_bonus, dmg_cost]
	_btn_dmg.disabled = not prog.can_afford(dmg_cost)

func _on_buy_life() -> void:
	var prog := get_node_or_null("/root/Progression")
	if prog and prog.buy_life_upgrade():
		_update_coins()
		_rebuild()

func _on_buy_damage() -> void:
	var prog := get_node_or_null("/root/Progression")
	if prog and prog.buy_damage_upgrade():
		_update_coins()
		_rebuild()
