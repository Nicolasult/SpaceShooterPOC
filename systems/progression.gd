extends Node

signal difficulty_changed(new_difficulty: String)
signal coins_changed(run: int, total: int)
signal levels_unlocked_changed(unlocked_max: int)   # émis quand on débloque un nouveau niveau

var _save_path: String = "user://save.json"

var difficulty: String = "Normal"
var unlocked_level: int = 0           # niveau max débloqué (ex: 1 => niveaux 0 et 1 accessibles si tu es en index 0-based)
var best_times: Dictionary = {}       # ex: {"L1:Normal": 32.5}

var coins_run: int = 0                # gagné depuis le début du niveau courant
var coins_total: int = 0              # cumulé (persisté)

func _ready() -> void:
	load_save()
	randomize()

# --- Difficulté ---
func get_difficulty() -> String:
	return difficulty

func set_difficulty(d: String) -> void:
	if d == difficulty:
		return
	difficulty = d
	emit_signal("difficulty_changed", d)
	save()

# --- Déblocage niveaux ---
# Compat: même sémantique que ton code existant
func is_unlocked(level_index: int) -> bool:
	return level_index <= unlocked_level

# Alias pratique pour les UIs (plus explicite côté menu)
func is_level_unlocked(idx: int) -> bool:
	return is_unlocked(idx)

func unlock_up_to(level_index: int) -> void:
	if level_index > unlocked_level:
		unlocked_level = level_index
		emit_signal("levels_unlocked_changed", unlocked_level)
		save()

# Appelle ceci à la fin d’un niveau i pour débloquer i+1
func unlock_next_after(idx: int) -> void:
	var next_idx: int = idx + 1
	if next_idx > unlocked_level:
		unlock_up_to(next_idx)

# --- Chronos ---
func record_time(level_id: String, time_s: float) -> void:
	var key: String = "%s:%s" % [level_id, difficulty]
	if not best_times.has(key) or time_s < float(best_times[key]):
		best_times[key] = time_s
		save()

# --- Sauvegarde ---
func save() -> void:
	var data: Dictionary = {
		"difficulty": difficulty,
		"unlocked_level": unlocked_level,
		"best_times": best_times,
		"coins_total": coins_total
	}
	var f: FileAccess = FileAccess.open(_save_path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()

func load_save() -> void:
	if not FileAccess.file_exists(_save_path):
		return
	var f: FileAccess = FileAccess.open(_save_path, FileAccess.READ)
	if f:
		var txt: String = f.get_as_text()
		f.close()
		var res: Variant = JSON.parse_string(txt)
		if typeof(res) == TYPE_DICTIONARY:
			var d: Dictionary = res
			difficulty = String(d.get("difficulty", "Normal"))
			unlocked_level = int(d.get("unlocked_level", 1))
			best_times = d.get("best_times", {})
			coins_total = int(d.get("coins_total", 0))

# --- Monnaie ---
func reset_run_coins() -> void:
	coins_run = 0
	emit_signal("coins_changed", coins_run, coins_total)

func add_coins(v: int) -> void:
	if v <= 0:
		return
	coins_run += v
	coins_total += v
	emit_signal("coins_changed", coins_run, coins_total)
	save() # on persiste les coins_total à chaque gain
