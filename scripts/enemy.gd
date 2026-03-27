extends Area2D

# Type d'ennemi (renommés pour le top-down)
enum EnemyType { BRUTE, SHOOTER }
var enemy_type: EnemyType = EnemyType.SHOOTER

# Stats
var health: int = 3
var max_health: int = 3
var speed: float = 150.0
var score_value: int = 50

# Pour le type SHOOTER
var shoot_cooldown: float = 2.0
var shoot_timer: float = 0.0
var bullet_scene: PackedScene

# Scène des compliments pour les drops
var compliment_scene: PackedScene

# Référence au joueur
var player = null

# Signaux
signal enemy_killed(score_value)
signal enemy_died  # Pour le compteur de vague

# Références nœuds
@onready var sprite = $Sprite2D
@onready var health_bar = $HealthBar

func _ready():
	body_entered.connect(_on_body_entered)
	add_to_group("enemies")

	# Charger les scènes
	bullet_scene = preload("res://scenes/game/enemy_bullet.tscn")
	compliment_scene = preload("res://scenes/game/compliment.tscn")

	# Initialiser la barre de vie
	update_health_bar()

	# Configurer l'apparence selon le type
	setup_appearance()

func setup(type: EnemyType, spawn_speed: float):
	enemy_type = type
	speed = spawn_speed

	# Configuration selon le type
	match enemy_type:
		EnemyType.BRUTE:
			max_health = 5
			health = 5
			score_value = 75
			speed = spawn_speed * 0.6  # Les brutes sont plus lentes
		EnemyType.SHOOTER:
			max_health = 3
			health = 3
			score_value = 50

func setup_appearance():
	if not sprite:
		return

	match enemy_type:
		EnemyType.BRUTE:
			sprite.modulate = Color(0.8, 0.4, 0.0)   # Orange foncé
		EnemyType.SHOOTER:
			sprite.modulate = Color(0.6, 0.0, 0.6)    # Violet

func _process(delta):
	# Récupérer le joueur si pas encore fait
	if not player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]

	# Comportement selon le type
	match enemy_type:
		EnemyType.BRUTE:
			process_brute_behavior(delta)
		EnemyType.SHOOTER:
			process_shooter_behavior(delta)

func process_brute_behavior(delta):
	# La brute fonce droit vers le joueur
	if player:
		var direction = global_position.direction_to(player.global_position)
		position += direction * speed * delta

func process_shooter_behavior(delta):
	# Le tireur se déplace vers le joueur
	if player:
		var direction = global_position.direction_to(player.global_position)
		position += direction * speed * delta

	# Tirer périodiquement en direction du joueur
	shoot_timer += delta
	if shoot_timer >= shoot_cooldown:
		shoot()
		shoot_timer = 0.0

func shoot():
	if not bullet_scene or not player:
		return

	# Créer un projectile dirigé vers le joueur
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = global_position.direction_to(player.global_position)

	get_parent().add_child(bullet)

func take_damage(amount: int):
	health -= amount
	update_health_bar()

	# Flash blanc pour feedback visuel
	if sprite:
		sprite.modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout
		setup_appearance()

	if health <= 0:
		die()

func die():
	emit_signal("enemy_killed", score_value)
	emit_signal("enemy_died")

	# Notifier le joueur
	if player and player.has_method("on_enemy_killed"):
		player.on_enemy_killed()

	# Drop compliment (10% de chance)
	if randf() < 0.10 and compliment_scene:
		var compliment = compliment_scene.instantiate()
		var types = ["motivation", "encouragement", "positif"]
		compliment.position = global_position
		compliment.setup(types[randi() % types.size()], 0.0, randf_range(1.5, 3.0))
		get_parent().add_child(compliment)

	queue_free()

func update_health_bar():
	if not health_bar:
		return

	var health_percentage = float(health) / float(max_health)
	health_bar.value = health_percentage * 100

func _on_body_entered(body):
	# Si le joueur touche l'ennemi directement
	if body.has_method("take_damage"):
		body.take_damage(1)
		# La brute ne meurt pas au contact, le tireur oui
		if enemy_type == EnemyType.SHOOTER:
			die()
