extends Control
class_name WaveBanner

@export var label_path: NodePath
@export var show_time: float = 1.2
@export var fade_time: float = 0.25

var _label: Label
var _tween: Tween   # <<--- corrige ici

func _ready():
	_label = get_node_or_null(label_path)
	if _label:
		_label.visible = false
		modulate.a = 0.0

func show_wave(index: int, name: String) -> void:
	if _label == null:
		return
	_label.text = "Wave %d" % index
	_label.visible = true
	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween()
	modulate.a = 0.0
	_tween.tween_property(self, "modulate:a", 1.0, fade_time)
	_tween.tween_interval(show_time)
	_tween.tween_property(self, "modulate:a", 0.0, fade_time).finished.connect(func():
		_label.visible = false)
