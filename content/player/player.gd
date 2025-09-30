extends CharacterBody2D

@export var move_speed: float = 200.0
@export var explosion_scene: PackedScene

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var _hp: Node = $Health
@onready var _hitbox: Area2D = $Hitbox
@onready var _weapon: Node = $Weapon
@onready var _stats: Stats = $Stats

var _dead: bool = false

func _ready() -> void:
	add_to_group("player")
	
	# Connexion à la mort du joueur
	if _hp and _hp.has_signal("died"):
		_hp.connect("died", Callable(self, "_on_player_dead"))

	# Option : caler la vitesse sur les stats si tu préfères
	if _stats:
		move_speed = _stats.move_speed

	# S'assure que l'anim est au neutre
	if _anim:
		_anim.play("center")

func _process(dt: float) -> void:
	# Tir auto (pas de déclenchement manuel)
	if not _dead and _weapon and _weapon.has_method("auto_fire"):
		_weapon.auto_fire(dt)

	# Choix d'animation en fonction de l'input horizontal
	_update_animation()

func _physics_process(_dt: float) -> void:
	if _dead:
		return

	# Mouvement basique avec actions standard (ui_left/right/up/down)
	var input_x: float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var input_y: float = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	var dir: Vector2 = Vector2(input_x, input_y)
	if dir.length_squared() > 1.0:
		dir = dir.normalized()

	velocity = dir * move_speed
	move_and_slide()

	# Clamp dans le viewport (on centre sur le sprite)
	_clamp_to_viewport()

func _update_animation() -> void:
	if _anim == null:
		return
	var vx: float = velocity.x
	var threshold: float = 10.0
	var target: String = "center"
	if vx < -threshold:
		target = "steering_left"
	elif vx > threshold:
		target = "steering_right"
	if _anim.animation != target:
		_anim.play(target)

func _clamp_to_viewport() -> void:
	var rect: Rect2 = get_viewport().get_visible_rect()
	# marge pour éviter de coller aux bords si besoin
	var margin: float = 0.0
	var pos: Vector2 = global_position
	pos.x = clamp(pos.x, rect.position.x + margin, rect.end.x - margin)
	pos.y = clamp(pos.y, rect.position.y + margin, rect.end.y - margin)
	global_position = pos

func _on_player_dead() -> void:
	if _dead:
		return
	_dead = true

	# Couper les collisions et le tir — en différé pour éviter le crash
	if _hitbox:
		_hitbox.set_deferred("monitoring", false)
		_hitbox.set_deferred("monitorable", false)

	if _weapon:
		_weapon.set_process(false)
		_weapon.set_physics_process(false)

	# Explosion (on peut la créer tout de suite)
	if explosion_scene:
		var fx: Node = explosion_scene.instantiate()
		if fx is Node2D:
			(fx as Node2D).global_position = global_position
		get_parent().add_child(fx)

	# Masquer immédiatement
	visible = false

	# Libération du joueur après la frame courante
	call_deferred("queue_free")
