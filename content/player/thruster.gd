extends AnimatedSprite2D
class_name Thruster

@export var atlas: Texture2D                      # ship_flame.png
@export var frame_size: Vector2i = Vector2i(16, 16)
@export var fps: float = 10.0
# 3 colonnes (left, center, right) × 2 lignes (2 frames)
@export var col_left: int = 0
@export var col_center: int = 1
@export var col_right: int = 2
@export var rows: int = 2

func _ready() -> void:
	_build_frames()
	play("center")

func set_state(state: String) -> void:
	# → on vérifie sur sprite_frames
	if sprite_frames and sprite_frames.has_animation(state) and animation != state:
		play(state)

func _build_frames() -> void:
	if atlas == null:
		return
	var fw := frame_size.x
	var fh := frame_size.y
	var frames := SpriteFrames.new()

	# steering_left
	frames.add_animation("steering_left")
	frames.set_animation_loop("steering_left", true)
	frames.set_animation_speed("steering_left", fps)
	for row in rows:
		var reg := Rect2i(col_left * fw, row * fh, fw, fh)
		var sub := AtlasTexture.new()
		sub.atlas = atlas
		sub.region = reg
		frames.add_frame("steering_left", sub)

	# center
	frames.add_animation("center")
	frames.set_animation_loop("center", true)
	frames.set_animation_speed("center", fps)
	for row in rows:
		var reg := Rect2i(col_center * fw, row * fh, fw, fh)
		var sub := AtlasTexture.new()
		sub.atlas = atlas
		sub.region = reg
		frames.add_frame("center", sub)

	# steering_right
	frames.add_animation("steering_right")
	frames.set_animation_loop("steering_right", true)
	frames.set_animation_speed("steering_right", fps)
	for row in rows:
		var reg := Rect2i(col_right * fw, row * fh, fw, fh)
		var sub := AtlasTexture.new()
		sub.atlas = atlas
		sub.region = reg
		frames.add_frame("steering_right", sub)

	sprite_frames = frames
