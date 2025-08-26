extends Node
class_name Spawner

signal wave_started(index: int, wave_name: String)
signal wave_cleared(index: int)
signal level_cleared()

@export var waves: Array[Wave] = []                 # Wave.tres
@export var viewport_margin: float = 40.0
@export var announce_banner_path: NodePath          # optionnel: WaveBanner
@export var debug_logs: bool = true                 # logs de diagnostic

var _wave_idx: int = -1
var _wave_time: float = 0.0
var _pending_events: Array[WaveEvent] = []
var _live_set: Dictionary = {}                      # { Node2D: true }
var _scheduled_spawns: int = 0                      # << NEW: spawns programmés mais pas encore instanciés
var _banner: Node = null
var _started: bool = false
var _banner_shown_for_idx: int = -999

func _ready() -> void:
	_banner = get_node_or_null(announce_banner_path)
	if debug_logs:
		print("[Spawner] READY path=", get_path(), " id=", get_instance_id())
		print("[Spawner] waves.size()=", waves.size(), " names=", _list_wave_names())
		print("[Spawner] other spawners in tree=", _count_spawners_in_tree())
	if not _started:
		_started = true
		_start_next_wave()
	elif debug_logs:
		print("[Spawner] _ready() ignored (already started) path=", get_path())

func _list_wave_names() -> Array[String]:
	var arr: Array[String] = []
	for w in waves: arr.append(w.name)
	return arr

func _count_spawners_in_tree() -> int:
	var n: int = 0
	var root := get_tree().get_root()
	for node in root.get_children():
		n += _count_spawners_recursive(node)
	return n

func _count_spawners_recursive(node: Node) -> int:
	var c: int = 1 if node is Spawner else 0
	for ch in node.get_children():
		c += _count_spawners_recursive(ch)
	return c

func _start_next_wave() -> void:
	_wave_idx += 1
	if debug_logs:
		print("[Spawner] START_NEXT idx=", _wave_idx, " path=", get_path())

	if _wave_idx >= waves.size():
		if debug_logs: print("[Spawner] LEVEL CLEARED")
		emit_signal("level_cleared"); return

	_wave_time = 0.0
	_live_set.clear()
	_scheduled_spawns = 0

	var w: Wave = waves[_wave_idx]
	_pending_events = w.events.duplicate(true)
	_pending_events.sort_custom(func(a: WaveEvent, b: WaveEvent) -> bool: return a.t < b.t)

	if debug_logs:
		print("[Spawner] wave_started idx=", _wave_idx, " name=", w.name, " events=", _pending_events.size())
	emit_signal("wave_started", _wave_idx, w.name)

	var display_idx := _wave_idx + 1
	if display_idx != _banner_shown_for_idx and _banner and _banner.has_method("show_wave"):
		_banner_shown_for_idx = display_idx
		call_deferred("_show_banner", display_idx, w.name)

func _show_banner(i: int, name: String) -> void:
	if _banner and _banner.has_method("show_wave"):
		if debug_logs: print("[Spawner] BANNER show_wave i=", i, " name=", name, " path=", get_path())
		_banner.call("show_wave", i, name)

func _process(dt: float) -> void:
	if _wave_idx < 0 or _wave_idx >= waves.size(): return

	_wave_time += dt

	# Déclenche les events à l'heure
	while _pending_events.size() > 0 and _pending_events[0].t <= _wave_time:
		var ev: WaveEvent = _pending_events.pop_front()
		_queue_spawn_event(ev)

	# Fin de vague SEULEMENT s'il ne reste plus rien à venir ni à apparaître
	if _pending_events.is_empty() and _scheduled_spawns == 0 and _live_set.size() == 0:
		if debug_logs: print("[Spawner] WAVE CLEARED idx=", _wave_idx, " path=", get_path())
		emit_signal("wave_cleared", _wave_idx)
		_start_next_wave()

func _queue_spawn_event(ev: WaveEvent) -> void:
	# Comptabilise les spawns prévus
	_scheduled_spawns += ev.count
	if debug_logs:
		print("[Spawner] queue event: +", ev.count, " scheduled ->", _scheduled_spawns)
	for i in ev.count:
		var delay: float = float(i) * ev.spawn_every
		var timer: SceneTreeTimer = get_tree().create_timer(delay)
		timer.timeout.connect(func() -> void: _spawn_one(ev))

func _spawn_one(ev: WaveEvent) -> void:
	# Un spawn se matérialise → décrémente d'abord
	_scheduled_spawns = max(0, _scheduled_spawns - 1)

	if ev.enemy_scene == null:
		push_warning("Spawner: enemy_scene manquante")
		return

	var enemy: Node2D = ev.enemy_scene.instantiate() as Node2D
	if enemy == null:
		push_warning("Spawner: la scène d'ennemi n'est pas un Node2D")
		return

	# Position X
	var x: float = ev.x_fixed
	if ev.x_mode == &"range":
		var minx: float = min(ev.x_range.x, ev.x_range.y)
		var maxx: float = max(ev.x_range.x, ev.x_range.y)
		x = randf_range(minx, maxx)
	enemy.global_position = Vector2(x, ev.start_y)

	# Mouvement
	if ev.movement:
		var mov: Movement = ev.movement.duplicate(true) as Movement
		for k in ev.movement_overrides.keys():
			var key: String = String(k)
			if _has_property(mov, StringName(key)):
				mov.set(key, ev.movement_overrides[k])
		if _has_property(enemy, &"movement"):
			enemy.set("movement", mov)

	# Wrap vertical auto si pas présent
	if ClassDB.class_exists("RecycleY") and enemy.get_node_or_null("RecycleY") == null:
		var ry := RecycleY.new()
		ry.name = "RecycleY"
		var rect: Rect2 = get_viewport().get_visible_rect()
		ry.bottom_margin = rect.end.y + viewport_margin
		ry.top_y = -viewport_margin
		enemy.add_child(ry)

	# Suivi des vivants
	_live_set[enemy] = true
	enemy.tree_exited.connect(func() -> void:
		if _live_set.has(enemy):
			_live_set.erase(enemy))
	var hp_node: Node = enemy.get_node_or_null("Health")
	if hp_node and hp_node.has_signal("died"):
		hp_node.connect("died", func() -> void:
			if _live_set.has(enemy):
				_live_set.erase(enemy))

	get_tree().current_scene.add_child(enemy)

# Helpers
func _has_property(obj: Object, prop: StringName) -> bool:
	for p in obj.get_property_list():
		if p is Dictionary and p.get("name", "") == String(prop):
			return true
	return false
