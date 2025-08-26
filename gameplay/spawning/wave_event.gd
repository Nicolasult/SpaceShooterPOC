extends Resource
class_name WaveEvent

@export var t: float = 0.0
@export var enemy_scene: PackedScene
@export var count: int = 1
@export var spawn_every: float = 0.2
@export var start_y: float = -32.0

@export var x_mode: StringName = &"range"  # "range" | "fixed"
@export var x_range: Vector2 = Vector2(64, 576)
@export var x_fixed: float = 320.0

@export var movement: Movement              # ex: MoveStraight.tres
@export var movement_overrides: Dictionary = {} # {"speed": 180.0, "amp": 32.0}
@export var mirror: bool = false
