extends Node3D

# Scènes à instancier
@export var comment_scene: PackedScene
@export var compliment_scene: PackedScene
@export var enemy_scene: PackedScene

# Paramètres de spawn
var spawn_rate: float = 2.0
var comment_speed: float = 200.0
var enemy_speed_mult: float = 0.8
var spawn_timer: float = 0.0

# Probabilité de spawn
var compliment_chance: float = 0.25
var enemy_chance: float = 0.20

# Rayon du cercle de spawn 3D (sur plan XZ)
const SPAWN_RADIUS = 50.0

# Types de débuffs
var debuff_types = ["lent", "nul", "fragile", "aveugle", "confus"]

var spawning_enabled: bool = false
var enemies_to_spawn: int = 0
var enemies_spawned: int = 0
var player = null

func _ready():
	if not comment_scene:
		comment_scene = preload("res://scenes/game/comment.tscn")
	if not compliment_scene:
		compliment_scene = preload("res://scenes/game/compliment.tscn")
	if not enemy_scene:
		enemy_scene = preload("res://scenes/game/enemy.tscn")

func _process(delta):
	if not spawning_enabled: return
	if not player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
		else: return

	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_entity()
		spawn_timer = spawn_rate

func get_spawn_position() -> Vector3:
	var angle = randf() * TAU
	var center = player.global_position if player else Vector3.ZERO
	return center + Vector3(cos(angle), 0, sin(angle)) * SPAWN_RADIUS

func spawn_entity():
	var rand = randf()
	if rand < compliment_chance and compliment_scene:
		spawn_compliment()
	elif rand < (compliment_chance + enemy_chance) and enemy_scene:
		if enemies_to_spawn <= 0 or enemies_spawned < enemies_to_spawn:
			spawn_enemy()
	elif comment_scene:
		spawn_negative_comment()

func spawn_negative_comment():
	if not comment_scene: return
	var spawn_pos = get_spawn_position()
	spawn_pos.y = 0.5
	var comment = comment_scene.instantiate()
	get_parent().add_child(comment)
	comment.global_position = spawn_pos
	var debuff_type = debuff_types[randi() % debuff_types.size()]
	var target_pos = player.global_position if player else Vector3.ZERO
	comment.setup(debuff_type, comment_speed, target_pos)

func spawn_compliment():
	if not compliment_scene: return
	var spawn_pos = get_spawn_position()
	spawn_pos.y = 0.5
	var compliment = compliment_scene.instantiate()
	get_parent().add_child(compliment)
	compliment.global_position = spawn_pos
	var compliment_types = ["motivation", "encouragement", "positif"]
	var compliment_type = compliment_types[randi() % compliment_types.size()]
	var healing_time = randf_range(1.5, 3.0)
	var target_pos = player.global_position if player else Vector3.ZERO
	compliment.setup(compliment_type, comment_speed, healing_time, target_pos)

func spawn_enemy():
	if not enemy_scene: return
	var enemy = enemy_scene.instantiate()
	enemy.position = get_spawn_position()
	enemy.position.y = 0.5
	var enemy_type = 0 if randf() < 0.5 else 1
	enemy.setup(enemy_type, comment_speed * enemy_speed_mult)
	enemy.enemy_killed.connect(_on_enemy_killed)
	var game_scene = get_parent()
	if game_scene and game_scene.has_method("on_enemy_died"):
		enemy.enemy_died.connect(game_scene.on_enemy_died)
	get_parent().add_child(enemy)
	enemies_spawned += 1

func configure_wave(config: Dictionary):
	spawn_rate = config.get("spawn_rate", 2.0)
	comment_speed = config.get("comment_speed", 200.0)
	enemy_speed_mult = config.get("enemy_speed_mult", 0.8)
	enemies_to_spawn = config.get("enemy_count", 5)
	enemies_spawned = 0

func start_wave_spawning(total_enemies: int):
	enemies_to_spawn = total_enemies
	enemies_spawned = 0
	spawning_enabled = true
	spawn_timer = 0.5

func start_spawning():
	spawning_enabled = true
	spawn_timer = spawn_rate
	var config = GameManager.get_wave_config(GameManager.current_wave)
	configure_wave(config)

func stop_spawning():
	spawning_enabled = false

func clear_all_entities():
	for group in ["comments", "enemies", "compliments"]:
		for entity in get_tree().get_nodes_in_group(group):
			entity.queue_free()

func _on_enemy_killed(score_value: int):
	GameManager.add_score(score_value)
