extends Area2D

var speed: float = 300.0
var damage: int = 1

@onready var sprite = $Sprite2D

func _ready():
	body_entered.connect(_on_body_entered)

func _process(delta):
	# Déplacer le projectile vers le bas
	position.y += speed * delta
	
	# Détruire si hors écran
	if position.y > 800:
		queue_free()

func _on_body_entered(body):
	# Si on touche le joueur
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
