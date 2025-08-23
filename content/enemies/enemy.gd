extends CharacterBody2D

@export var movement: Movement
@onready var hp: Node = $Health

func _ready():
	hp.connect("died", Callable(self, "_on_dead"))
func _physics_process(dt):
	velocity = movement.velocity(self, dt)
	move_and_slide()
func _on_dead():
	queue_free()
