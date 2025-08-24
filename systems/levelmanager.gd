extends Node

signal level_started(level_id)
signal level_stopped(level_id, time_elapsed, grade)

var current_level_id: String = ""
var _timer_running := false
var _t0 := 0.0

# Difficulté courante (prends celle de Progression si dispo)
var difficulty: String = "Normal"

# Profils de difficulté simples
var profiles := {
	"Easy":   {"enemy_hp_mult": 0.9, "enemy_damage_mult": 0.9, "player_hp_mult": 1.1, "player_damage_mult": 1.1},
	"Normal": {"enemy_hp_mult": 1.0, "enemy_damage_mult": 1.0, "player_hp_mult": 1.0, "player_damage_mult": 1.0},
	"Hard":   {"enemy_hp_mult": 1.2, "enemy_damage_mult": 1.1, "player_hp_mult": 0.9, "player_damage_mult": 0.95}
}

func _ready():
	if has_node("/root/Progression"):
		var p = get_node("/root/Progression")
		if p.has_method("get_difficulty"):
			difficulty = p.get_difficulty()

func start_level(level_id: String) -> void:
	current_level_id = level_id
	_t0 = Time.get_ticks_msec() / 1000.0
	_timer_running = true
	emit_signal("level_started", level_id)

func stop_level(grade: String = "") -> void:
	if not _timer_running: return
	var elapsed := get_time_elapsed()
	_timer_running = false
	emit_signal("level_stopped", current_level_id, elapsed, grade)
	current_level_id = ""

func get_time_elapsed() -> float:
	if not _timer_running: return 0.0
	return (Time.get_ticks_msec() / 1000.0) - _t0

# --- Multiplicateurs de dégâts selon la cible ---
# Appelé par Damageable: LevelManager.get_damage_taken_mult(node)
func get_damage_taken_mult(node: Node) -> float:
	var prof = profiles.get(difficulty, profiles["Normal"])
	if node.is_in_group("enemy"):
		# dégâts reçus par un ennemi = dégâts infligés par le joueur => on peut jouer sur ce levier
		return 1.0 / float(prof.get("enemy_hp_mult", 1.0))  # ennemis plus tanky => prennent moins par coup
	elif node.is_in_group("player"):
		# dégâts reçus par le joueur
		return float(prof.get("enemy_damage_mult", 1.0))
	return 1.0

# Exemple de grading simple basé sur le temps (à adapter par niveau)
func grade_time(elapsed: float) -> String:
	# S < 30s, A < 40s, B < 55s sinon C
	if elapsed < 30.0: return "S"
	if elapsed < 40.0: return "A"
	if elapsed < 55.0: return "B"
	return "C"
