extends CharacterBody3D

# Type d'ennemi
enum EnemyType { BRUTE, SHOOTER }
var enemy_type: EnemyType = EnemyType.SHOOTER

# Stats
var health: int = 3
var max_health: int = 3
var speed: float = 8.0 # Vitesse 3D ajustée
var score_value: int = 50
var knockback_velocity: Vector3 = Vector3.ZERO

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
@onready var visual_root = $VisualRoot
@onready var mesh = $VisualRoot/MeshInstance3D

func _ready():
	add_to_group("enemies")

	# Connecter le signal de hitbox
	var hitbox = get_node_or_null("Hitbox")
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

	# Charger les scènes
	bullet_scene = preload("res://scenes/game/enemy_bullet.tscn")
	compliment_scene = preload("res://scenes/game/compliment.tscn")

	# Configurer l'apparence selon le type
	setup_appearance()

func setup(type: int, spawn_speed: float):
	enemy_type = type as EnemyType
	speed = spawn_speed * 0.05 # Conversion approximative 2D -> 3D speed

	match enemy_type:
		EnemyType.BRUTE:
			max_health = 5
			health = 5
			score_value = 75
			speed = speed * 0.6
		EnemyType.SHOOTER:
			max_health = 3
			health = 3
			score_value = 50

func setup_appearance():
	if not mesh: return
	var mat = StandardMaterial3D.new()
	mesh.set_surface_override_material(0, mat)

	match enemy_type:
		EnemyType.BRUTE:
			mat.albedo_color = Color(0.8, 0.4, 0.0)
		EnemyType.SHOOTER:
			mat.albedo_color = Color(0.6, 0.0, 0.6)

func _process(delta):
	if not player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]

	if enemy_type == EnemyType.SHOOTER:
		shoot_timer += delta
		if shoot_timer >= shoot_cooldown:
			shoot()
			shoot_timer = 0.0

func _physics_process(delta):
	if player:
		var dir = (player.global_position - global_position).normalized()
		dir.y = 0
		velocity = dir * speed + knockback_velocity
		look_at(Vector3(player.global_position.x, position.y, player.global_position.z), Vector3.UP)
		move_and_slide()

		# Decay knockback
		knockback_velocity = knockback_velocity.lerp(Vector3.ZERO, 10.0 * delta)

func shoot():
	if not bullet_scene or not player: return
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position - transform.basis.z * 1.5
	bullet.direction = -transform.basis.z
	get_parent().add_child(bullet)

func take_damage(amount: int):
	health -= amount

	# Flash visuel
	if mesh:
		var mat = mesh.get_surface_override_material(0)
		if mat:
			var old_color = mat.albedo_color
			mat.albedo_color = Color(10, 10, 10)
			var tween = create_tween()
			tween.tween_property(mat, "albedo_color", old_color, 0.1)

	# Screen shake via signal ou accès direct (comme dans enemy.gd original)
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var game_scene = get_parent()
		if game_scene and game_scene.get("camera") and game_scene.camera.has_method("add_shake"):
			game_scene.camera.add_shake(3.0)

	if health <= 0:
		die()

func _on_hitbox_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(1)
		if enemy_type == EnemyType.SHOOTER:
			die()

func die():
	emit_signal("enemy_killed", score_value)
	emit_signal("enemy_died")
	if player and player.has_method("on_enemy_killed"):
		player.on_enemy_killed()

	if randf() < 0.10 and compliment_scene:
		var compliment = compliment_scene.instantiate()
		compliment.position = global_position
		var types = ["motivation", "encouragement", "positif"]
		compliment.setup(types[randi() % types.size()], 0.0, randf_range(1.5, 3.0))
		get_parent().add_child(compliment)

	queue_free()

func apply_knockback(kv: Vector3):
	knockback_velocity += kv
