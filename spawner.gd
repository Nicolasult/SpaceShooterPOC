extends Node
class_name Spawner

signal wave_started(index: int, wave_name: String)
signal wave_cleared(index: int)
signal level_cleared()

@export var waves: Array[Wave] = []                # Resources Wave.tres
@export var viewport_margin: float = 40.0
@export var announce_banner_path: NodePath         # (optionnel) vers un WaveBanner

var _wave_idx: int = -1
var _wave_time: float = 0.0
var _pending_events: Array[WaveEvent] = []         # << typé
var _live_set: Dictionary = {}                     # {Node: true}
var _banner: Node = null

func _ready() -> void:
	_banner = get_node_or_null(announce_banner_path)
	_start_next_wave()

func _start_next_wave() -> void:
	_wave_idx += 1
	if _wave_idx >= waves.size():
		emit_signal("level_cleared")
		return

	_wave_time = 0.0
	_live_set.clear()

	var w: Wave = waves[_wave_idx]                  # << typé
	_pending_events = w.events.duplicate(true)
	_pending_events.sort_custom(self, "_cmp_events")

	emit_signal("wave_started", _wave_idx, w.name)
	if _banner and _banner.has_method("show_wave"):
		_banner.call("show_wave", _wave_idx + 1, w.name)

func _cmp_events(a: WaveEvent, b: WaveEvent) -> bool:
	return a.t < b.t

func _process(dt: float) -> void:
	if _wave_idx < 0 or _wave_idx >= waves.size():
		return

	_wave_time += dt

	while _pending_events.size() > 0 and _pending_events[0].t <= _wave_time:
		var ev: WaveEvent = _pending_events.pop_front()
		_queue_spawn_event(ev)

	if _pending_events.is_empty() and _live_set.size() == 0:
		emit_signal("wave_cleared", _wave_idx)
		_start_next_wave()

func _queue_spawn_event(ev: WaveEvent) -> void:
	for i in ev.count:
		var delay: float = float(i) * ev.spawn_every
		var timer := get_tree().create_timer(delay)
		timer.timeout.connect(func() -> void: _spawn_one(ev))

func _spawn_one(ev: WaveEvent) -> void:
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

	# Mouvement : duplique la Resource et applique les overrides typés
	if ev.movement:
		var mov: Movement = ev.movement.duplicate(true) as Movement
		for k in ev.movement_overrides.keys():
			var key: StringName = StringName(String(k))
			if _has_property(mov, key):
				mov.set(String(key), ev.movement_overrides[k])
		if _has_property(enemy, &"movement"):
			enemy.set("movement", mov)

	# Wrap vertical (si tu n'as pas mis le composant dans la scène Enemy)
	if ClassDB.class_exists("RecycleY") and enemy.get_node_or_null("RecycleY") == null:
		var ry := RecycleY.new()
		ry.name = "RecycleY"
		var rect: Rect2 = get_viewport().get_visible_rect()
		ry.bottom_margin = rect.end.y + viewport_margin
		ry.top_y = -viewport_margin
		enemy.add_child(ry)

	_live_set[enemy] = true
	enemy.tree_exited.connect(func() -> void:
		if _live_set.has(enemy): _live_set.erase(enemy))

	get_tree().current_scene.add_child(enemy)

# --- Helpers ---

func _has_property(obj: Object, prop: StringName) -> bool:
	var plist: Array = obj.get_property_list()
	for p in plist:
		if p is Dictionary and p.get("name", "") == String(prop):
			return true
	return false
