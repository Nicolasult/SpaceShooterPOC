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
	# instancier l'explosion avant de se détruire
	if explosion_scene:
		var fx = explosion_scene.instantiate()
		fx.global_position = global_position
		get_tree().current_scene.add_child(fx)
		
	if coin_scene and randf() < coin_drop_chance:
		var coin := coin_scene.instantiate() as Node2D
		if coin:
			coin.global_position = global_position
			if coin.has_method("set_value"):
				coin.call("set_value", coin_value)
			get_tree().current_scene.add_child(coin)
				
	queue_free()
