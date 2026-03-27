extends Area2D

var speed: float = 300.0
var damage: int = 1
var direction: Vector2 = Vector2.DOWN  # Direction vers le joueur au moment du tir
var spawn_position: Vector2 = Vector2.ZERO

@onready var sprite = $Sprite2D

func _ready():
	body_entered.connect(_on_body_entered)
	spawn_position = global_position
	add_to_group("enemy_bullets")

func _process(delta):
	# Déplacer le projectile dans la direction voulue
	position += direction * speed * delta

	# Détruire si trop éloigné du point d'origine
	if global_position.distance_to(spawn_position) > 1200:
		queue_free()

func _on_body_entered(body):
	# Si on touche le joueur
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
