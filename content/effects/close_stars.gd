extends Sprite2D
@export var twinkle_amp: float = 0.08
@export var twinkle_freq: float = 0.9
var _t: float = 0.0
func _process(dt: float) -> void:
	_t += dt
	var a := 1.0 + twinkle_amp * sin(_t * TAU * twinkle_freq)
	modulate.a = clamp(a, 0.6, 1.0)
