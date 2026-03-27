extends Area2D

var speed: float = 600.0
var damage: int = 1
var direction: Vector2 = Vector2.RIGHT  # Direction de tir (définie par le joueur)
var piercing: bool = false  # Balles perçantes en mode immunité émotionnelle
var spawn_position: Vector2 = Vector2.ZERO

@onready var sprite = $Sprite2D

func _ready():
	area_entered.connect(_on_area_entered)
	spawn_position = global_position

func _process(delta):
	# Déplacer le projectile dans la direction visée
	position += direction * speed * delta

	# Détruire si trop éloigné du point de spawn (hors arène)
	if global_position.distance_to(spawn_position) > 1400:
		queue_free()

func _on_area_entered(area):
	# Si on touche un ennemi
	if area.has_method("take_damage"):
		area.take_damage(damage)
		if not piercing:
			queue_free()
