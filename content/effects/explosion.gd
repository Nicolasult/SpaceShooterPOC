extends Node2D
@export var animation_name: StringName = &"explode"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Assure le départ propre
	anim.play(animation_name)
	# Quand l'anim se termine, on détruit la scène
	anim.connect("animation_finished", Callable(self, "_on_anim_finished"))

func _on_anim_finished() -> void:
	queue_free()
