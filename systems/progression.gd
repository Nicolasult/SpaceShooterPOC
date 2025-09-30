extends Node

signal difficulty_changed(new_difficulty: String)
signal coins_changed(run: int, total: int)
signal levels_unlocked_changed(unlocked_max: int)
signal ships_changed()                     # propriété “vaisseaux possédés” modifiée
signal selected_ship_changed(id: StringName)

var _save_path: String = "user://save.json"

var difficulty: String = "Normal"
var unlocked_level: int = 0
var best_times: Dictionary = {}            # {"L1:Normal": 32.5}

var coins_run: int = 0
var coins_total: int = 0

# --- Vaisseaux ---
var owned_ships: Array[StringName] = [ &"starter" ]  # starter possédé par défaut
var selected_ship: StringName = &"starter"

func _ready() -> void:
	load_save()
	randomize()

# --- Difficulté (inchangé) ---
func get_difficulty() -> String: return difficulty
func set_difficulty(d: String) -> void:
	if d == difficulty: return
	difficulty = d
	emit_signal("difficulty_changed", d)
	save()

# --- Déblocage niveaux (inchangé) ---
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

# --- Chronos (inchangé) ---
func record_time(level_id: String, time_s: float) -> void:
	var key: String = "%s:%s" % [level_id, difficulty]
	if not best_times.has(key) or time_s < float(best_times[key]):
		best_times[key] = time_s
		save()

# --- Monnaie (légère maj: save après gain) ---
func reset_run_coins() -> void:
	coins_run = 0
	emit_signal("coins_changed", coins_run, coins_total)

func add_coins(v: int) -> void:
	if v <= 0: return
	coins_run += v
	coins_total += v
	emit_signal("coins_changed", coins_run, coins_total)
	save()

func can_afford(cost: int) -> bool:
	return coins_total >= cost

func spend_coins(v: int) -> bool:
	if v <= 0: return true
	if coins_total < v: return false
	coins_total -= v
	emit_signal("coins_changed", coins_run, coins_total)
	save()
	return true

# --- Vaisseaux: propriété/achats/sélection ---
func is_ship_owned(id: StringName) -> bool:
	return id in owned_ships

func buy_ship(id: StringName, cost: int) -> bool:
	if is_ship_owned(id): return true
	if not can_afford(cost): return false
	if not spend_coins(cost): return false
	owned_ships.append(id)
	emit_signal("ships_changed")
	save()
	return true

func select_ship(id: StringName) -> bool:
	if not is_ship_owned(id): return false
	if selected_ship == id: return true
	selected_ship = id
	emit_signal("selected_ship_changed", id)
	save()
	return true

# --- Sauvegarde / Chargement ---
func save() -> void:
	var data: Dictionary = {
		"difficulty": difficulty,
		"unlocked_level": unlocked_level,
		"best_times": best_times,
		"coins_total": coins_total,
		"owned_ships": owned_ships,
		"selected_ship": String(selected_ship),
	}
	var f: FileAccess = FileAccess.open(_save_path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()

func load_save() -> void:
	if not FileAccess.file_exists(_save_path): return
	var f: FileAccess = FileAccess.open(_save_path, FileAccess.READ)
	if not f: return
	var txt: String = f.get_as_text()
	f.close()
	var res: Variant = JSON.parse_string(txt)
	if typeof(res) != TYPE_DICTIONARY: return
	var d: Dictionary = res
	difficulty = String(d.get("difficulty", "Normal"))
	unlocked_level = max(0, int(d.get("unlocked_level", 0)))
	best_times = d.get("best_times", {})
	coins_total = int(d.get("coins_total", 0))
	# ships
	var owned_arr: Array = d.get("owned_ships", [ "starter" ])
	owned_ships.clear()
	for it in owned_arr:
		owned_ships.append(StringName(String(it)))
	selected_ship = StringName(String(d.get("selected_ship", "starter")))
	# garde-fous
	if owned_ships.is_empty():
		owned_ships = [ &"starter" ]
	if not (&"starter" in owned_ships):
		owned_ships.append(&"starter")
	if not is_ship_owned(selected_ship):
		selected_ship = &"starter"
