extends CanvasLayer
class_name LevelEndOverlay

@onready var _msg: Label = $Root/Panel/VBox/Msg
@onready var _sub: Label = $Root/Panel/VBox/Sub
@onready var _root: Control = $Root   # le Control principal

func show_message(text: String, sub: String = "") -> void:
	visible = true
	_msg.text = text
	_sub.text = sub
	_root.modulate.a = 0.0
	create_tween().tween_property(_root, "modulate:a", 1.0, 0.25)

func hide_now() -> void:
	visible = false
