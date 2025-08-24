extends CharacterBody2D

@export var explosion_scene: PackedScene
@export var movement: Movement

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
	queue_free()
