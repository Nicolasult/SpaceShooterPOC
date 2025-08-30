extends CharacterBody2D

@export var explosion_scene: PackedScene
@export var movement: Movement

@export_range(0.0, 1.0, 0.01) var coin_drop_chance: float = 0.25
@export var coin_scene: PackedScene
@export var coin_value: int = 1

@onready var hp: Node = $Health

func _ready():
	hp.connect("died", Callable(self, "_on_dead"))

func _physics_process(dt):
	if movement == null:
		print("movement is NULL")
		return
	velocity = movement.velocity(self, dt)
	move_and_slide()
	
func _on_dead():
	# On capture la position et on désactive la collision de l’ennemi tout de suite
	var pos := global_position

	# Si tu as des Area2D/CollisionShape2D sur l’ennemi :
	for a in get_children():
		if a is Area2D:
			a.set_deferred("monitoring", false)
			a.set_deferred("monitorable", false)

	# On fait TOUT le reste après le flush de physique
	call_deferred("_do_after_death", pos)

func _do_after_death(pos: Vector2) -> void:
	# 1) Explosion
	if explosion_scene:
		var fx := explosion_scene.instantiate()
		if fx is Node2D:
			fx.global_position = pos
		get_tree().current_scene.add_child(fx)

	# 2) Coin drop
	if coin_scene and randf() < coin_drop_chance:
		var coin := coin_scene.instantiate() as Node2D
		if coin:
			coin.global_position = pos + Vector2(0, 6)
			if coin.has_method("set_value"):
				coin.call("set_value", coin_value)
			get_tree().current_scene.add_child(coin)

	# 3) Libération de l’ennemi (après avoir spawn FX/coin)
	queue_free()
