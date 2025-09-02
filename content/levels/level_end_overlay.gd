extends CanvasLayer
class_name LevelEndOverlay

# Renseigne ces NodePath dans l'inspecteur selon TON arbo (ou garde les valeurs si tu as ces noms)
@export var root_path: NodePath = ^"Root"                       # un Control (le panneau complet)
@export var msg_label_path: NodePath = ^"Root/Panel/VBox/Msg"   # Label du message principal
@export var sub_label_path: NodePath = ^"Root/Panel/VBox/Sub"   # Label secondaire

var _root: Control = null
var _msg: Label = null
var _sub: Label = null

func _ready() -> void:
	_root = get_node_or_null(root_path) as Control
	_msg = get_node_or_null(msg_label_path) as Label
	_sub = get_node_or_null(sub_label_path) as Label

	# Fallbacks si les chemins ne matchent pas: on essaie de trouver les 2 premiers Label sous Root
	if _root and (_msg == null or _sub == null):
		var labels := _root.get_tree().get_nodes_in_group(&"") # pas utile ici; on parcourt simplement:
		var found: Array[Label] = []
		for n in _root.get_children(true):
			if n is Label:
				found.append(n)
		if _msg == null and found.size() >= 1: _msg = found[0]
		if _sub == null and found.size() >= 2: _sub = found[1]

	visible = false  # caché au départ

func show_message(text: String, sub: String = "") -> void:
	visible = true
	if _msg: _msg.text = text
	if _sub: _sub.text = sub

	# Effet de fondu sur le Control (CanvasLayer n'a pas "modulate")
	if _root:
		_root.modulate.a = 0.0
		create_tween().tween_property(_root, "modulate:a", 1.0, 0.25)

func hide_now() -> void:
	visible = false
