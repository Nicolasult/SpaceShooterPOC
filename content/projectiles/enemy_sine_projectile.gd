extends Area2D
class_name EnemySineProjectile

@export var speed_down: float = 220.0
@export var amplitude_px: float = 24.0
@export var frequency_hz: float = 1.2
@export var lifetime: float = 3.0
@export var damage: float = 10.0
@export var tags: Array[String] = ["enemy", "laser"]

var _t: float = 0.0
var _x0: float = 0.0

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D

func set_damage(v: float) -> void:
	damage = v

func _ready() -> void:
	_x0 = global_position.x
	connect("area_entered", Callable(self, "_on_area_entered"))
	if _anim and _anim.sprite_frames:
		# Joue l’anim par défaut (ex: "idle" / "loop")
		if _anim.sprite_frames.has_animation(_anim.animation):
			_anim.play(_anim.animation)
		else:
			_anim.play()

func _physics_process(dt: float) -> void:
	_t += dt

	# Descente droite (Y) + oscillation sinus (X)
	var y := global_position.y + speed_down * dt
	var x := _x0 + amplitude_px * sin(TAU * frequency_hz * _t)
	global_position = Vector2(x, y)

	# Auto-destruction (durée / hors écran)
	if _t >= lifetime:
		queue_free()
		return
	var rect: Rect2 = get_viewport().get_visible_rect()
	if global_position.y > rect.end.y + 48.0:
		queue_free()

func _on_area_entered(a: Area2D) -> void:
	if a and a.has_method("apply_damage"):
		var ev := DamageEvent.new()
		ev.amount = damage
		ev.tags = tags
		a.apply_damage(ev)
		queue_free()
