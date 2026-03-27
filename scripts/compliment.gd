extends Area2D

# Type de compliment
var compliment_type: String = "motivation"
var compliment_text: String = ""
var speed: float = 0.0  # Vitesse de déplacement (0 = statique comme loot drop)
var direction: Vector2 = Vector2.ZERO
var healing_time: float = 2.0  # Durée de réduction de l'affliction
var despawn_timer: float = 8.0  # Durée avant auto-despawn si non collecté

# Références
@onready var label = $Label
@onready var sprite = $Sprite2D

# Textes des compliments
const COMPLIMENT_TEXTS = {
	"motivation": ["T'es FORT!", "Excellent!", "Bien joué!", "Continue!", "Bravo!"],
	"encouragement": ["Tu gères!", "Superbe!", "Incroyable!", "Champion!", "Parfait!"],
	"positif": ["T'assures!", "Top!", "Génial!", "Respect!", "GG!"]
}

# Couleur dorée pour les compliments
const COMPLIMENT_COLOR = Color(1.0, 0.9, 0.0)  # Doré

func _ready():
	body_entered.connect(_on_body_entered)
	add_to_group("compliments")
	set_compliment_appearance()

func setup(type: String, spawn_speed: float, heal_time: float, target_position: Vector2 = Vector2.ZERO):
	compliment_type = type
	healing_time = heal_time

	# Choisir un texte aléatoire
	var texts = COMPLIMENT_TEXTS.get(type, ["Bravo!"])
	compliment_text = texts[randi() % texts.size()]

	if spawn_speed > 0 and target_position != Vector2.ZERO:
		# Mode "volant" : se déplace vers le joueur
		speed = spawn_speed
		direction = (target_position - global_position).normalized()
		if direction == Vector2.ZERO:
			direction = Vector2.DOWN
	else:
		# Mode "loot drop" : statique, attend d'être collecté
		speed = 0.0
		direction = Vector2.ZERO

func set_compliment_appearance():
	if label:
		label.text = compliment_text
		label.modulate = COMPLIMENT_COLOR

	if sprite:
		sprite.modulate = COMPLIMENT_COLOR

func _process(delta):
	# Déplacer si en mode volant
	if speed > 0:
		position += direction * speed * delta

	# Effet de brillance (rotation)
	if sprite:
		sprite.rotation += delta * 2.0

	# Auto-despawn progressif (clignote avant de disparaître)
	despawn_timer -= delta
	if despawn_timer <= 2.0 and despawn_timer > 0:
		# Clignoter pour signaler la disparition imminente
		if sprite:
			sprite.visible = fmod(despawn_timer, 0.4) > 0.2
	if despawn_timer <= 0:
		queue_free()

func _on_body_entered(body):
	if body.has_method("collect_compliment"):
		body.collect_compliment(healing_time)
		queue_free()
