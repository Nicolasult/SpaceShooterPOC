extends Resource
class_name WaveEvent

@export var t: float = 0.0                         # Horodatage (sec) dans la vague
@export var enemy_scene: PackedScene               # Scène Enemy.tscn / GreenEnemy.tscn
@export var count: int = 1                         # Combien d’ennemis
@export var spawn_every: float = 0.2               # Intervalle entre chaque spawn
@export var start_y: float = -32.0                 # Position Y de spawn (au-dessus de l’écran)
@export var x_mode: String = "range"               # "range" | "fixed"
@export var x_range: Vector2 = Vector2(64, 576)    # Si mode range: minX..maxX
@export var x_fixed: float = 320.0                 # Si mode fixed
@export var movement: Movement                     # Resource Movement (ex: MoveStraight/MoveZigZag)
@export var movement_overrides: Dictionary = {}    # { "speed": 220.0, "amp": 32.0 } etc.
@export var mirror: bool = false                   # miroir horizontal (multiplie x par -1 en interne si utilisé)
