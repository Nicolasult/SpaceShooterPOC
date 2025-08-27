extends Node
class_name RecycleY

@export var bottom_offset: float = 32.0   # wrap dès qu'on sort de 8px
@export var top_offset: float = 32.0     # réapparaît 32px au-dessus

var _bottom_y: float
var _top_y: float

func _ready() -> void:
	var rect: Rect2 = get_viewport().get_visible_rect()
	_bottom_y = rect.end.y + bottom_offset
	_top_y = rect.position.y - top_offset

func _process(_dt: float) -> void:
	var p := get_parent()
	if p is Node2D and p.global_position.y > _bottom_y:
		p.global_position.y = _top_y
