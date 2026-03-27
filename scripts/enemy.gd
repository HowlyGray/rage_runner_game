extends Area2D

# Type d'ennemi
enum EnemyType { WALL, SHOOTER }
var enemy_type: EnemyType = EnemyType.SHOOTER

# Stats
var health: int = 3
var max_health: int = 3
var speed: float = 150.0
var score_value: int = 50

# Pour le type WALL
var wall_target_y: float = 400.0  # Position où le mur se stabilise
var is_wall_positioned: bool = false

# Pour le type SHOOTER
var shoot_cooldown: float = 2.0
var shoot_timer: float = 0.0
var bullet_scene: PackedScene

# Références
@onready var sprite = $Sprite2D
@onready var health_bar = $HealthBar

# Signaux
signal enemy_killed(score_value)

func _ready():
	body_entered.connect(_on_body_entered)
	
	# Charger la scène du projectile ennemi
	bullet_scene = preload("res://scenes/game/enemy_bullet.tscn")
	
	# Initialiser la barre de vie
	update_health_bar()
	
	# Configurer l'apparence selon le type
	setup_appearance()

func setup(type: EnemyType, spawn_speed: float):
	enemy_type = type
	speed = spawn_speed
	
	# Configuration selon le type
	match enemy_type:
		EnemyType.WALL:
			max_health = 5
			health = 5
			score_value = 75
		EnemyType.SHOOTER:
			max_health = 3
			health = 3
			score_value = 50

func setup_appearance():
	if not sprite:
		return
	
	match enemy_type:
		EnemyType.WALL:
			sprite.modulate = Color(0.8, 0.4, 0.0)  # Orange foncé
		EnemyType.SHOOTER:
			sprite.modulate = Color(0.6, 0.0, 0.6)  # Violet

func _process(delta):
	match enemy_type:
		EnemyType.WALL:
			process_wall_behavior(delta)
		EnemyType.SHOOTER:
			process_shooter_behavior(delta)
	
	# Détruire si hors écran (bas)
	if position.y > 800:
		queue_free()

func process_wall_behavior(delta):
	if not is_wall_positioned:
		# Descendre jusqu'à la position cible
		position.y += speed * delta
		
		if position.y >= wall_target_y:
			position.y = wall_target_y
			is_wall_positioned = true
			speed = 0  # Arrêter le mouvement
	else:
		# Rester en place et bloquer le chemin
		pass

func process_shooter_behavior(delta):
	# Descendre lentement
	position.y += speed * delta
	
	# Tirer périodiquement
	shoot_timer += delta
	if shoot_timer >= shoot_cooldown:
		shoot()
		shoot_timer = 0.0

func shoot():
	if not bullet_scene:
		return
	
	# Créer un projectile
	var bullet = bullet_scene.instantiate()
	bullet.position = position + Vector2(0, 30)  # Un peu en dessous de l'ennemi
	
	# Ajouter à la scène
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
	
	# Notifier le joueur qu'il a tué cet ennemi
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("on_enemy_killed"):
		player.on_enemy_killed()
	
	# Effet de destruction (optionnel - pour l'instant juste disparaître)
	queue_free()

func update_health_bar():
	if not health_bar:
		return
	
	var health_percentage = float(health) / float(max_health)
	health_bar.value = health_percentage * 100

func _on_body_entered(body):
	# Si le joueur touche l'ennemi directement (collision)
	if body.has_method("take_damage"):
		body.take_damage(1)
		# L'ennemi type WALL ne meurt pas au contact
		if enemy_type == EnemyType.SHOOTER:
			die()
