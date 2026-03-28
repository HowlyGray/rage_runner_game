extends Area3D

# Type de débuff que ce commentaire inflige
var debuff_type: String = "lent"
var comment_text: String = ""
var speed: float = 10.0 # Vitesse 3D
var direction: Vector3 = Vector3.BACK
var spawn_position: Vector3 = Vector3.ZERO
var is_dodged: bool = false

# Références
@onready var label = $Label3D # Utilisation de Label3D pour le texte dans le monde 3D
@onready var mesh = $MeshInstance3D

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

func setup(type: String, spawn_speed: float, target_position: Vector3 = Vector3.ZERO):
	debuff_type = type
	speed = spawn_speed * 0.05

	var texts = COMMENT_TEXTS.get(type, ["Commentaire rageux!"])
	comment_text = texts[randi() % texts.size()]

	if target_position != Vector3.ZERO:
		direction = (target_position - global_position).normalized()
		direction.y = 0
		if direction == Vector3.ZERO:
			direction = Vector3.BACK

func set_comment_appearance():
	if label:
		label.text = comment_text
		label.modulate = DEBUFF_COLORS.get(debuff_type, Color.WHITE)

	if mesh:
		var mat = StandardMaterial3D.new()
		mesh.set_surface_override_material(0, mat)
		mat.albedo_color = DEBUFF_COLORS.get(debuff_type, Color.WHITE)

func _process(delta):
	position += direction * speed * delta

	if global_position.distance_to(spawn_position) > 100.0:
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
