extends Area2D

# Type de débuff que ce commentaire inflige
var debuff_type: String = "lent"
var comment_text: String = ""
var speed: float = 200.0
var direction: Vector2 = Vector2.DOWN  # Direction fixée au moment du spawn
var spawn_position: Vector2 = Vector2.ZERO
var is_dodged: bool = false # Pour éviter de compter plusieurs esquives pour le même projectile

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
	spawn_position = global_position
	add_to_group("comments")
	set_comment_appearance()

func setup(type: String, spawn_speed: float, target_position: Vector2 = Vector2.ZERO):
	debuff_type = type
	speed = spawn_speed

	# Choisir un texte aléatoire pour ce type de commentaire
	var texts = COMMENT_TEXTS.get(type, ["Commentaire rageux!"])
	comment_text = texts[randi() % texts.size()]

	# Calculer la direction vers le joueur au moment du spawn
	if target_position != Vector2.ZERO:
		direction = (target_position - global_position).normalized()
		if direction == Vector2.ZERO:
			direction = Vector2.DOWN

func set_comment_appearance():
	if label:
		label.text = comment_text
		label.modulate = DEBUFF_COLORS.get(debuff_type, Color.WHITE)

	if sprite:
		sprite.modulate = DEBUFF_COLORS.get(debuff_type, Color.WHITE)

func _process(delta):
	# Déplacer le commentaire dans la direction fixée vers le joueur
	position += direction * speed * delta

	# Détruire si trop éloigné de la position de spawn
	if global_position.distance_to(spawn_position) > 1500:
		queue_free()

func _on_body_entered(body):
	if body.has_method("apply_debuff"):
		body.apply_debuff(debuff_type)
		queue_free()

func set_as_dodged():
	if not is_dodged:
		is_dodged = true
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			players[0].on_comment_dodged()
