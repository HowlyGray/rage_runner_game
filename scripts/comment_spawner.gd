extends Node2D

# Scènes à instancier
@export var comment_scene: PackedScene
@export var compliment_scene: PackedScene
@export var enemy_scene: PackedScene

# Paramètres de spawn
var spawn_rate: float = 2.0  # Temps entre chaque spawn
var comment_speed: float = 200.0
var enemy_speed_mult: float = 0.8
var spawn_timer: float = 0.0

# Probabilité de spawn (compliment vs commentaire)
var compliment_chance: float = 0.25  # 25% de chance d'avoir un compliment
var enemy_chance: float = 0.20  # 20% de chance d'avoir un ennemi

# Rayon du cercle de spawn autour du joueur
const SPAWN_RADIUS = 700.0

# Types de débuffs disponibles
var debuff_types = ["lent", "nul", "fragile", "aveugle", "confus"]

# Contrôle du spawn
var spawning_enabled: bool = false

# Quota d'ennemis pour la vague courante
var enemies_to_spawn: int = 0
var enemies_spawned: int = 0

# Référence au joueur (récupérée dynamiquement)
var player = null

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

	# Récupérer la référence joueur si pas encore fait
	if not player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
		else:
			return

	spawn_timer -= delta

	if spawn_timer <= 0:
		spawn_entity()
		spawn_timer = spawn_rate

func get_spawn_position() -> Vector2:
	# Position aléatoire sur un cercle autour du joueur
	var angle = randf() * TAU
	var center = player.global_position if player else Vector2(640, 360)
	return center + Vector2.RIGHT.rotated(angle) * SPAWN_RADIUS

func spawn_entity():
	# Décider aléatoirement ce qui va spawner
	var rand = randf()

	if rand < compliment_chance and compliment_scene:
		spawn_compliment()
	elif rand < (compliment_chance + enemy_chance) and enemy_scene:
		# Respecter le quota d'ennemis de la vague
		if enemies_to_spawn <= 0 or enemies_spawned < enemies_to_spawn:
			spawn_enemy()
	elif comment_scene:
		spawn_negative_comment()

func spawn_negative_comment():
	if not comment_scene:
		return

	var comment = comment_scene.instantiate()
	var spawn_pos = get_spawn_position()
	comment.position = spawn_pos

	# Type de débuff aléatoire
	var debuff_type = debuff_types[randi() % debuff_types.size()]

	# Configurer avec la direction vers le joueur
	var target_pos = player.global_position if player else Vector2(640, 360)
	comment.setup(debuff_type, comment_speed, target_pos)

	get_parent().add_child(comment)

func spawn_compliment():
	if not compliment_scene:
		return

	var compliment = compliment_scene.instantiate()
	var spawn_pos = get_spawn_position()
	compliment.position = spawn_pos

	# Types de compliments
	var compliment_types = ["motivation", "encouragement", "positif"]
	var compliment_type = compliment_types[randi() % compliment_types.size()]

	# Temps de guérison aléatoire
	var healing_time = randf_range(1.5, 3.0)

	# Configurer avec direction vers le joueur
	var target_pos = player.global_position if player else Vector2(640, 360)
	compliment.setup(compliment_type, comment_speed, healing_time, target_pos)

	get_parent().add_child(compliment)

func spawn_enemy():
	if not enemy_scene:
		return

	var enemy = enemy_scene.instantiate()
	var spawn_pos = get_spawn_position()
	enemy.position = spawn_pos

	# Décider le type d'ennemi selon brute_ratio
	# 0 = BRUTE (ex-WALL), 1 = TIREUR (ex-SHOOTER)
	var enemy_type = 0 if randf() < 0.5 else 1

	# Configurer l'ennemi
	enemy.setup(enemy_type, comment_speed * enemy_speed_mult)

	# Connecter les signaux
	enemy.enemy_killed.connect(_on_enemy_killed)
	# Connecter le signal de mort au compteur de vague dans game_scene
	var game_scene = get_parent()
	if game_scene and game_scene.has_method("on_enemy_died"):
		enemy.enemy_died.connect(game_scene.on_enemy_died)

	get_parent().add_child(enemy)
	enemies_spawned += 1

func configure_wave(config: Dictionary):
	# Appliquer la configuration de la vague
	spawn_rate = config.get("spawn_rate", 2.0)
	comment_speed = config.get("comment_speed", 200.0)
	enemy_speed_mult = config.get("enemy_speed_mult", 0.8)
	enemies_to_spawn = config.get("enemy_count", 5)
	enemies_spawned = 0

func start_wave_spawning(total_enemies: int):
	enemies_to_spawn = total_enemies
	enemies_spawned = 0
	spawning_enabled = true
	spawn_timer = 0.5  # Petit délai avant le premier spawn

func start_spawning():
	spawning_enabled = true
	spawn_timer = spawn_rate

	# Configurer selon la vague actuelle
	var config = GameManager.get_wave_config(GameManager.current_wave)
	configure_wave(config)

func stop_spawning():
	spawning_enabled = false

func clear_all_comments():
	# Supprimer tous les commentaires actifs
	var comments = get_tree().get_nodes_in_group("comments")
	for comment in comments:
		comment.queue_free()

func clear_all_entities():
	# Supprimer tous les ennemis, commentaires et compliments
	clear_all_comments()
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.queue_free()
	var compliments = get_tree().get_nodes_in_group("compliments")
	for compliment in compliments:
		compliment.queue_free()

func _on_enemy_killed(score_value: int):
	# Ajouter du score quand un ennemi est tué
	GameManager.add_score(score_value)
