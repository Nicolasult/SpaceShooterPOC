extends Node
# NOTE: Script utilisé en Autoload sous le nom "Progression". Ne pas ajouter class_name.

# --- Signals ---
signal difficulty_changed(new_difficulty: String)
signal coins_changed(run: int, total: int)
signal levels_unlocked_changed(unlocked_max: int)
signal ships_changed()
signal selected_ship_changed(id: StringName)
signal upgrades_changed()

# --- Sauvegarde ---
var _save_path: String = "user://save.json"

# --- Progression générale ---
var difficulty: String = "Normal"

# Indice max débloqué (0-based). 0 => seul le niveau 0 est jouable au départ.
var unlocked_level: int = 0
var best_times: Dictionary = {}   # ex: {"L1:Normal": 32.5}

# --- Monnaie ---
var coins_run: int = 0
var coins_total: int = 0

# --- Vaisseaux ---
var owned_ships: Array[StringName] = [ &"starter" ]  # starter possédé par défaut
var selected_ship: StringName = &"starter"

# --- Upgrades ---
var life_level: int = 0
var damage_level: int = 0

var life_base_cost: int = 5
var life_cost_growth: float = 1.5
var life_per_level: int = 20            # +20 HP par niveau

var damage_base_cost: int = 5
var damage_cost_growth: float = 1.5
var damage_per_level: float = 2.0       # +2 dégâts par niveau

func _ready() -> void:
	load_save()
	randomize()

# =========================
#        DIFFICULTÉ
# =========================
func get_difficulty() -> String:
	return difficulty

func set_difficulty(d: String) -> void:
	if d == difficulty:
		return
	difficulty = d
	emit_signal("difficulty_changed", d)
	save()

# =========================
#      NIVEAUX / DÉBLOCAGE
# =========================
func is_unlocked(level_index: int) -> bool:
	return level_index <= unlocked_level

func is_level_unlocked(idx: int) -> bool:
	return is_unlocked(idx)

func unlock_up_to(level_index: int) -> void:
	if level_index > unlocked_level:
		unlocked_level = level_index
		emit_signal("levels_unlocked_changed", unlocked_level)
		save()

func unlock_next_after(idx: int) -> void:
	var next_idx: int = idx + 1
	if next_idx > unlocked_level:
		unlock_up_to(next_idx)

# =========================
#          CHRONOS
# =========================
func record_time(level_id: String, time_s: float) -> void:
	var key: String = "%s:%s" % [level_id, difficulty]
	if not best_times.has(key) or time_s < float(best_times[key]):
		best_times[key] = time_s
		save()

# =========================
#          MONNAIE
# =========================
func reset_run_coins() -> void:
	coins_run = 0
	emit_signal("coins_changed", coins_run, coins_total)

func add_coins(v: int) -> void:
	if v <= 0:
		return
	coins_run += v
	coins_total += v
	emit_signal("coins_changed", coins_run, coins_total)
	save()

func can_afford(cost: int) -> bool:
	return coins_total >= cost

func spend_coins(v: int) -> bool:
	if v <= 0:
		return true
	if coins_total < v:
		return false
	coins_total -= v
	emit_signal("coins_changed", coins_run, coins_total)
	save()
	return true

# =========================
#         VAISSEAUX
# =========================
func is_ship_owned(id: StringName) -> bool:
	return id in owned_ships

func buy_ship(id: StringName, cost: int) -> bool:
	if is_ship_owned(id):
		return true
	if not can_afford(cost):
		return false
	if not spend_coins(cost):
		return false
	owned_ships.append(id)
	emit_signal("ships_changed")
	save()
	return true

func select_ship(id: StringName) -> bool:
	if not is_ship_owned(id):
		return false
	if selected_ship == id:
		return true
	selected_ship = id
	emit_signal("selected_ship_changed", id)
	save()
	return true

# =========================
#          UPGRADES
# =========================
func get_life_next_cost() -> int:
	return int(round(life_base_cost * pow(life_cost_growth, float(life_level))))

func get_damage_next_cost() -> int:
	return int(round(damage_base_cost * pow(damage_cost_growth, float(damage_level))))

func get_life_bonus() -> int:
	return life_level * life_per_level

func get_damage_bonus() -> float:
	return float(damage_level) * damage_per_level

func buy_life_upgrade() -> bool:
	var cost: int = get_life_next_cost()
	if not can_afford(cost):
		return false
	if not spend_coins(cost):
		return false
	life_level += 1
	emit_signal("upgrades_changed")
	save()
	return true

func buy_damage_upgrade() -> bool:
	var cost: int = get_damage_next_cost()
	if not can_afford(cost):
		return false
	if not spend_coins(cost):
		return false
	damage_level += 1
	emit_signal("upgrades_changed")
	save()
	return true

# Appliquer les upgrades au joueur instancié (Starter/Falcon partagent le même script)
# Attendu: enfant "Stats" avec propriétés max_hp et damage ; enfant "Health" avec max_hp, hp
func apply_upgrades_to(player: Node) -> void:
	if player == null:
		return
	var stats: Node = player.get_node_or_null("Stats")
	if stats:
		if "max_hp" in stats:
			stats.max_hp = float(stats.max_hp) + float(get_life_bonus())
		if "damage" in stats:
			stats.damage = float(stats.damage) + float(get_damage_bonus())

	var health: Node = player.get_node_or_null("Health")
	if health and stats:
		if ("max_hp" in health) and ("hp" in health) and ("max_hp" in stats):
			health.max_hp = float(stats.max_hp)
			health.hp = float(health.max_hp)

# =========================
#     SAUVEGARDE/CHARGEMENT
# =========================
func save() -> void:
	var data: Dictionary = {
		"difficulty": difficulty,
		"unlocked_level": unlocked_level,
		"best_times": best_times,
		"coins_total": coins_total,
		"owned_ships": owned_ships,
		"selected_ship": String(selected_ship),

		"life_level": life_level,
		"damage_level": damage_level,
	}
	var f: FileAccess = FileAccess.open(_save_path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()

func load_save() -> void:
	if not FileAccess.file_exists(_save_path):
		return
	var f: FileAccess = FileAccess.open(_save_path, FileAccess.READ)
	if f == null:
		return
	var txt: String = f.get_as_text()
	f.close()
	var res: Variant = JSON.parse_string(txt)
	if typeof(res) != TYPE_DICTIONARY:
		return
	var d: Dictionary = res

	difficulty = String(d.get("difficulty", "Normal"))
	unlocked_level = max(0, int(d.get("unlocked_level", 0)))
	best_times = d.get("best_times", {})
	coins_total = int(d.get("coins_total", 0))

	# ships
	var owned_arr: Array = d.get("owned_ships", ["starter"])
	owned_ships.clear()
	for it in owned_arr:
		owned_ships.append(StringName(String(it)))
	selected_ship = StringName(String(d.get("selected_ship", "starter")))
	if owned_ships.is_empty():
		owned_ships = [ &"starter" ]
	if not (&"starter" in owned_ships):
		owned_ships.append(&"starter")
	if not is_ship_owned(selected_ship):
		selected_ship = &"starter"

	# upgrades
	life_level = int(d.get("life_level", 0))
	damage_level = int(d.get("damage_level", 0))
