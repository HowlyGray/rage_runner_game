extends Node2D

# Scène du commentaire à instancier
@export var comment_scene: PackedScene
@export var compliment_scene: PackedScene
@export var enemy_scene: PackedScene

# Paramètres de spawn
var spawn_rate: float = 2.0  # Temps entre chaque spawn
var comment_speed: float = 200.0
var spawn_timer: float = 0.0

# Probabilité de spawn (compliment vs commentaire)
var compliment_chance: float = 0.25  # 25% de chance d'avoir un compliment
var enemy_chance: float = 0.20  # 20% de chance d'avoir un ennemi

# Zone de spawn (haut de l'écran)
const SPAWN_Y = -50
const SPAWN_X_MIN = 100
const SPAWN_X_MAX = 1180

# Types de débuffs disponibles
var debuff_types = ["lent", "nul", "fragile", "aveugle", "confus"]

# Activer/désactiver le spawn
var spawning_enabled: bool = false

func _ready():
	if not comment_scene:
		comment_scene = preload("res://scenes/game/comment.tscn")
	if not compliment_scene:
		compliment_scene = preload("res://scenes/game/compliment.tscn")
	if not enemy_scene:
		enemy_scene = preload("res://scenes/game/enemy.tscn")

func _process(delta):
	if not spawning_enabled:
		return
	
	spawn_timer -= delta
	
	if spawn_timer <= 0:
		spawn_comment()
		spawn_timer = spawn_rate

func spawn_comment():
	# Décider aléatoirement ce qui va spawner
	var rand = randf()
	
	if rand < compliment_chance and compliment_scene:
		# Spawn compliment
		spawn_compliment()
	elif rand < (compliment_chance + enemy_chance) and enemy_scene:
		# Spawn ennemi
		spawn_enemy()
	elif comment_scene:
		# Spawn commentaire négatif
		spawn_negative_comment()

func spawn_negative_comment():
	if not comment_scene:
		return
	
	# Créer une instance du commentaire
	var comment = comment_scene.instantiate()
	
	# Position aléatoire sur l'axe X
	var spawn_x = randf_range(SPAWN_X_MIN, SPAWN_X_MAX)
	comment.position = Vector2(spawn_x, SPAWN_Y)
	
	# Type de débuff aléatoire
	var debuff_type = debuff_types[randi() % debuff_types.size()]
	
	# Configurer le commentaire
	comment.setup(debuff_type, comment_speed)
	
	# Ajouter à la scène
	get_parent().add_child(comment)

func spawn_compliment():
	if not compliment_scene:
		return
	
	# Créer une instance du compliment
	var compliment = compliment_scene.instantiate()
	
	# Position aléatoire sur l'axe X
	var spawn_x = randf_range(SPAWN_X_MIN, SPAWN_X_MAX)
	compliment.position = Vector2(spawn_x, SPAWN_Y)
	
	# Types de compliments
	var compliment_types = ["motivation", "encouragement", "positif"]
	var compliment_type = compliment_types[randi() % compliment_types.size()]
	
	# Temps de guérison aléatoire (1 à 3 secondes)
	var healing_time = randf_range(1.5, 3.0)
	
	# Configurer le compliment
	compliment.setup(compliment_type, comment_speed, healing_time)
	
	# Ajouter à la scène
	get_parent().add_child(compliment)

func start_spawning():
	spawning_enabled = true
	spawn_timer = spawn_rate
	
	# Configurer selon le niveau actuel
	var config = GameManager.get_level_config()
	spawn_rate = config.spawn_rate
	comment_speed = config.comment_speed

func stop_spawning():
	spawning_enabled = false

func clear_all_comments():
	# Supprimer tous les commentaires actifs
	var comments = get_tree().get_nodes_in_group("comments")
	for comment in comments:
		comment.queue_free()

func spawn_enemy():
	if not enemy_scene:
		return
	
	# Créer une instance de l'ennemi
	var enemy = enemy_scene.instantiate()
	
	# Position aléatoire sur l'axe X
	var spawn_x = randf_range(SPAWN_X_MIN, SPAWN_X_MAX)
	enemy.position = Vector2(spawn_x, SPAWN_Y)
	
	# Décider le type d'ennemi (50% WALL, 50% SHOOTER)
	var enemy_type = 1 if randf() < 0.5 else 0  # 0 = WALL, 1 = SHOOTER
	
	# Configurer l'ennemi
	enemy.setup(enemy_type, comment_speed * 0.7)  # Un peu plus lent que les commentaires
	
	# Connecter le signal de mort pour ajouter du score
	enemy.enemy_killed.connect(_on_enemy_killed)
	
	# Ajouter à la scène
	get_parent().add_child(enemy)

func _on_enemy_killed(score_value: int):
	# Ajouter du score quand un ennemi est tué
	GameManager.add_score(score_value)
