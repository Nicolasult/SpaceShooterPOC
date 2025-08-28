extends ParallaxBackground

@export var base_speed: float = 80.0   # vitesse de défilement "référence" (px/s)

@onready var _space: ParallaxLayer = $Space
@onready var _far:   ParallaxLayer = $FarStars
@onready var _close: ParallaxLayer = $CloseStars

func _ready() -> void:
	# Réglage des facteurs de parallaxe (proche = bouge plus)
	# y < 0 inverserait le sens ; ici on scrolle vers le bas, donc +Y
	_space.motion_scale  = Vector2(0.10, 0.10)  # fond très lointain (le + lent)
	_far.motion_scale    = Vector2(0.25, 0.25)  # étoiles lointaines
	_close.motion_scale  = Vector2(0.50, 0.50)  # étoiles proches (le + rapide)

	# Caler automatiquement le mirroring sur la taille des textures
	_set_mirroring_from_sprite(_space)
	_set_mirroring_from_sprite(_far)
	_set_mirroring_from_sprite(_close)

func _process(dt: float) -> void:
	# On avance l’offset du parallax. Les motion_scale font le reste.
	scroll_offset.y += base_speed * dt

func _set_mirroring_from_sprite(layer: ParallaxLayer) -> void:
	var spr := layer.get_child(0) as Sprite2D
	if spr and spr.texture:
		var tex_size := spr.texture.get_size()
		# Si tu veux boucler en X aussi quand la caméra bougera latéralement :
		layer.motion_mirroring = tex_size        # (Vector2(width, height))
		# Si tu ne veux boucler qu'en Y : layer.motion_mirroring = Vector2(0.0, tex_size.y)
