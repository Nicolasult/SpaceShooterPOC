extends CharacterBody2D

@export var move_speed: float = 300.0
@export var weapon_path: NodePath
@onready var weapon = get_node_or_null(weapon_path)

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@export var clamp_to_viewport := true
var _viewport_rect: Rect2

func _ready():
	if clamp_to_viewport:
		_viewport_rect = get_viewport().get_visible_rect()
	if weapon == null and has_node("Weapon"):
		weapon = $Weapon

func _physics_process(dt):
	# déplacements
	var input_vec := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	velocity = input_vec * move_speed
	move_and_slide()

	# Clamp écran
	if clamp_to_viewport:
		global_position.x = clamp(global_position.x, _viewport_rect.position.x + 16.0, _viewport_rect.end.x - 16.0)
		global_position.y = clamp(global_position.y, _viewport_rect.position.y + 16.0, _viewport_rect.end.y - 16.0)

	# Animation selon l’axe X
	_update_animation(input_vec.x)

	# Tir auto → c’est Weapon qui s’occupe du timing
	if weapon:
		weapon.auto_fire(dt)

func _update_animation(x_axis: float) -> void:
	var dead_zone := 0.15
	if abs(x_axis) <= dead_zone:
		if anim.animation != "center":
			anim.play("center")
	elif x_axis < -dead_zone:
		if anim.animation != "steering_left":
			anim.play("steering_left")
	else:
		if anim.animation != "steering_right":
			anim.play("steering_right")
