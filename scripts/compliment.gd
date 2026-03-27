extends Area2D

# Type de compliment
var compliment_type: String = "motivation"
var compliment_text: String = ""
var speed: float = 200.0
var healing_time: float = 2.0  # Durée de réduction de l'affliction

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
	set_compliment_appearance()

func setup(type: String, spawn_speed: float, heal_time: float):
	compliment_type = type
	speed = spawn_speed
	healing_time = heal_time
	
	# Choisir un texte aléatoire
	var texts = COMPLIMENT_TEXTS.get(type, ["Bravo!"])
	compliment_text = texts[randi() % texts.size()]

func set_compliment_appearance():
	if label:
		label.text = compliment_text
		label.modulate = COMPLIMENT_COLOR
	
	if sprite:
		sprite.modulate = COMPLIMENT_COLOR

func _process(delta):
	# Déplacer le compliment vers le bas
	position.y += speed * delta
	
	# Ajouter un effet de brillance (optionnel)
	if sprite:
		sprite.rotation += delta * 2.0
	
	# Détruire le compliment s'il sort de l'écran
	if position.y > 800:
		queue_free()

func _on_body_entered(body):
	if body.has_method("collect_compliment"):
		body.collect_compliment(healing_time)
		queue_free()
