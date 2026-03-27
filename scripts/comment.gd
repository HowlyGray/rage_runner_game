extends Area2D

# Type de débuff que ce commentaire inflige
var debuff_type: String = "lent"
var comment_text: String = ""
var speed: float = 200.0

# Références
@onready var label = $Label
@onready var sprite = $Sprite2D

# Textes des commentaires selon le type de débuff
const COMMENT_TEXTS = {
	"lent": ["T'es trop LENT!", "Bouge plus vite!", "Escargot!", "Ralentis pas!"],
	"nul": ["T'es NUL!", "Noob!", "Apprends à jouer!", "Pathétique!"],
	"fragile": ["T'es FRAGILE!", "Cassable!", "Sensible!", "Trop faible!"],
	"aveugle": ["T'es AVEUGLE?", "Ouvre les yeux!", "Tu vois rien!", "Regarde mieux!"],
	"confus": ["T'es PERDU?", "Confus?", "Désorganisé!", "Concentre-toi!"]
}

# Couleurs selon le type
const DEBUFF_COLORS = {
	"lent": Color(0.3, 0.3, 1.0),      # Bleu
	"nul": Color(1.0, 0.3, 0.3),       # Rouge
	"fragile": Color(1.0, 0.7, 0.0),   # Orange
	"aveugle": Color(0.5, 0.5, 0.5),   # Gris
	"confus": Color(0.8, 0.0, 0.8)     # Violet
}

func _ready():
	body_entered.connect(_on_body_entered)
	set_comment_appearance()

func setup(type: String, spawn_speed: float):
	debuff_type = type
	speed = spawn_speed
	
	# Choisir un texte aléatoire pour ce type de commentaire
	var texts = COMMENT_TEXTS.get(type, ["Commentaire rageux!"])
	comment_text = texts[randi() % texts.size()]

func set_comment_appearance():
	if label:
		label.text = comment_text
		label.modulate = DEBUFF_COLORS.get(debuff_type, Color.WHITE)
	
	if sprite:
		sprite.modulate = DEBUFF_COLORS.get(debuff_type, Color.WHITE)

func _process(delta):
	# Déplacer le commentaire vers le bas
	position.y += speed * delta
	
	# Détruire le commentaire s'il sort de l'écran
	if position.y > 800:
		queue_free()

func _on_body_entered(body):
	if body.has_method("apply_debuff"):
		body.apply_debuff(debuff_type)
		queue_free()
