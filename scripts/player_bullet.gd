extends Area2D

var speed: float = 600.0
var damage: int = 1

@onready var sprite = $Sprite2D

func _ready():
	area_entered.connect(_on_area_entered)

func _process(delta):
	# Déplacer le projectile vers le haut
	position.y -= speed * delta
	
	# Détruire si hors écran
	if position.y < -50:
		queue_free()

func _on_area_entered(area):
	# Si on touche un ennemi
	if area.has_method("take_damage"):
		area.take_damage(damage)
		queue_free()
