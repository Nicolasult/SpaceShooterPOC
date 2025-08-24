extends Node

signal difficulty_changed(new_difficulty)

var _save_path := "user://save.json"

var difficulty: String = "Normal"
var unlocked_level: int = 1
var best_times := {}  # ex: {"L1:Normal": 32.5}

func _ready():
	load_save()

func get_difficulty() -> String:
	return difficulty

func set_difficulty(d: String) -> void:
	if d == difficulty: return
	difficulty = d
	emit_signal("difficulty_changed", d)
	save()

func is_unlocked(level_index: int) -> bool:
	return level_index <= unlocked_level

func unlock_up_to(level_index: int) -> void:
	if level_index > unlocked_level:
		unlocked_level = level_index
		save()

func record_time(level_id: String, time_s: float) -> void:
	var key := "%s:%s" % [level_id, difficulty]
	if not best_times.has(key) or time_s < float(best_times[key]):
		best_times[key] = time_s
		save()

func save() -> void:
	var data = {
		"difficulty": difficulty,
		"unlocked_level": unlocked_level,
		"best_times": best_times
	}
	var f := FileAccess.open(_save_path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()

func load_save() -> void:
	if not FileAccess.file_exists(_save_path):
		return
	var f := FileAccess.open(_save_path, FileAccess.READ)
	if f:
		var txt := f.get_as_text()
		f.close()
		var res = JSON.parse_string(txt)
		if typeof(res) == TYPE_DICTIONARY:
			difficulty = str(res.get("difficulty", "Normal"))
			unlocked_level = int(res.get("unlocked_level", 1))
			best_times = res.get("best_times", {})
