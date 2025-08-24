extends Area2D

@export var speed: float = 700.0        # vitesse du projectile
@export var lifetime: float = 2.0       # durée de vie max (secondes)
@export var damage: float = 10.0        # dégâts infligés
@export var tags: Array[String] = ["laser", "player"]

var _t := 0.0

func _ready():
	# Connecte le signal de collision
	connect("area_entered", Callable(self, "_on_area_entered"))

func _physics_process(delta: float) -> void:
	# Déplacement vers le haut
	global_position.y -= speed * delta

	# Timer de vie
	_t += delta
	if _t >= lifetime:
		queue_free()

	# Sécurité : si hors écran, détruire
	var rect = get_viewport().get_visible_rect()
	if global_position.y < rect.position.y - 50:
		queue_free()

func _on_area_entered(a: Area2D) -> void:
	# Vérifie si la cible peut prendre des dégâts
	if a.has_method("apply_damage"):
		var ev := DamageEvent.new()
		ev.amount = damage
		ev.tags = tags
		a.apply_damage(ev)
		queue_free()
