extends Node
class_name Spawner

signal wave_started(index: int, wave_name: String)
signal wave_cleared(index: int)
signal level_cleared()

@export var waves: Array[Wave] = []          # Assigne tes Wave.tres ici (Wave 1, 2, 3…)
@export var viewport_margin: float = 40.0    # marge hors écran pour wrap/check
@export var announce_banner_path: NodePath   # vers un WaveBanner (optionnel)

var _wave_idx: int = -1
var _wave_time: float = 0.0
var _pending_events: Array[WaveEvent] = []
var _spawn_acc: float = 0.0

var _live_set := {}   # { enemy_instance: true } pour la vague courante
var _banner

func _ready():
	_banner = get_node_or_null(announce_banner_path)
	start_first_wave()

func start_first_wave():
	if waves.is_empty():
		push_warning("Spawner: aucune vague définie")
		return
	_wave_idx = -1
	_start_next_wave()

func _start_next_wave():
	_wave_idx += 1
	if _wave_idx >= waves.size():
		emit_signal("level_cleared")
		return
	_wave_time = 0.0
	_live_set.clear()

	var w := waves[_wave_idx]
	_pending_events = w.events.duplicate(true)
	# tri par temps t
	_pending_events.sort_custom(func(a, b): return a.t < b.t)

	emit_signal("wave_started", _wave_idx, w.name)
	if _banner and _banner.has_method("show_wave"):
		_banner.show_wave(_wave_idx + 1, w.name)

func _process(delta):
	if _wave_idx < 0 or _wave_idx >= waves.size():
		return

	_wave_time += delta

	# Déclenche les events arrivés à échéance
	while _pending_events.size() > 0 and _pending_events[0].t <= _wave_time:
		var ev: WaveEvent = _pending_events.pop_front()
		_queue_spawn_event(ev)

	# Quand il n’y a plus d’événements à venir ET plus aucun ennemi vivant → vague finie
	if _pending_events.is_empty() and _live_set.size() == 0:
		emit_signal("wave_cleared", _wave_idx)
		_start_next_wave()

func _queue_spawn_event(ev: WaveEvent):
	# Spawns échelonnés: on utilise un Timer local pour count * spawn_every
	var total := ev.count
	for i in total:
		var delay := float(i) * ev.spawn_every
		var timer := get_tree().create_timer(delay)
		timer.timeout.connect(func():
			_spawn_one(ev))

func _spawn_one(ev: WaveEvent):
	if ev.enemy_scene == null:
		push_warning("Spawner: enemy_scene manquante dans un WaveEvent")
		return

	var enemy = ev.enemy_scene.instantiate()
	# Position X
	var x: float = ev.x_fixed
	if ev.x_mode == "range":
		var minx := min(ev.x_range.x, ev.x_range.y)
		var maxx := max(ev.x_range.x, ev.x_range.y)
		x = randf_range(minx, maxx)

	enemy.global_position = Vector2(x, ev.start_y)

	# Assigne movement si présent (duplique la Resource pour éviter l’état partagé)
	if ev.movement:
		var mov := ev.movement.duplicate(true)
		# Applique overrides si les propriétés existent
		for k in ev.movement_overrides.keys():
			if mov.has_property(k):
				mov.set(k, ev.movement_overrides[k])
		# si l’ennemi a un export 'movement'
		if enemy.has_variable("movement"):
			enemy.movement = mov

	# Ajoute un composant de wrap vertical si tu veux que tous les ennemis reviennent par le haut
	# (tu peux aussi l’avoir déjà dans la scène Enemy)
	if not enemy.has_node("RecycleY"):
		var ry := RecycleY.new()
		enemy.add_child(ry)
		ry.name = "RecycleY"
		ry.bottom_margin = get_viewport().get_visible_rect().end.y + viewport_margin
		ry.top_y = -viewport_margin

	# Suivi des vivants
	_live_set[enemy] = true
	# Quand l’ennemi est libéré → enlève-le du set
	enemy.tree_exited.connect(func():
		if _live_set.has(enemy):
			_live_set.erase(enemy))

	get_tree().current_scene.add_child(enemy)
