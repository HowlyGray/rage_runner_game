extends CharacterBody3D

# Signaux
signal hit_by_comment(debuff_type)
signal debuff_applied(debuff_type, duration)
signal debuff_expired(debuff_type)
signal compliment_collected(healing_time)
signal affliction_changed(affliction_time)
signal health_changed(current_health, max_health)
signal player_died
signal confidence_changed(confidence, is_immune, immunity_time)
signal enemy_killed_by_player
signal ammo_changed(current_ammo, max_ammo, is_reloading)
signal blanks_changed(blanks_remaining)

# Machine à états principale
enum State { NORMAL, STUNNED, IMMUNE, DODGING }
var current_state: State = State.NORMAL

# Constantes
const BASE_SPEED = 15.0  # Vitesse 3D ajustée
const BUFF_SPEED_MULTIPLIER = 1.3  # +30% de vitesse en buff

# Variables de mouvement
var current_speed: float = BASE_SPEED
var dodge_speed: float = 30.0
var dodge_duration: float = 0.3
var dodge_cooldown: float = 0.6
var dodge_timer: float = 0.0
var dodge_cooldown_timer: float = 0.0
var dodge_direction: Vector3 = Vector3.ZERO

# Système de vie
var health: int = 3
var max_health: int = 3
var invincible: bool = false
var invincible_duration: float = 1.5

# Système de confiance en soi
var confidence: float = 50.0
var max_confidence: float = 100.0
var min_confidence: float = 0.0
var is_emotionally_immune: bool = false
var immunity_duration: float = 0.0
var immunity_timer: float = 0.0

# Combo d'esquives
var dodge_combo: int = 0
var last_dodge_time: float = 0.0
const DODGE_COMBO_TIMEOUT = 3.0  # Temps max entre esquives pour maintenir le combo

# Gains/pertes de confiance
const CONFIDENCE_DODGE_GAIN = 5.0
const CONFIDENCE_COMBO_BONUS = 2.0  # Bonus par combo
const CONFIDENCE_KILL_GAIN = 10.0
const CONFIDENCE_COMPLIMENT_GAIN = 8.0
const CONFIDENCE_HIT_LOSS = 15.0
const CONFIDENCE_DAMAGE_LOSS = 20.0

# Durée d'immunité émotionnelle
const IMMUNITY_MIN_DURATION = 5.0
const IMMUNITY_MAX_DURATION = 8.0

# Système de tir 360°
var can_shoot: bool = true
var shoot_cooldown: float = 0.15 # Plus rapide pour Enter the Gungeon feel
var shoot_timer: float = 0.0
var bullet_scene: PackedScene

# Système de munitions
var max_ammo: int = 12
var current_ammo: int = 12
var is_reloading: bool = false
var reload_time: float = 1.2
var reload_timer: float = 0.0
var bullet_spread: float = 0.1 # Radians

# Système de Blanks
var blanks: int = 2
var max_blanks: int = 2
var blank_radius: float = 50.0 # Rayon 3D ajusté

# Débuffs actifs
var active_debuffs = {}
var inverted_controls: bool = false
var reduced_visibility: bool = false

# Système d'affliction
var affliction_time: float = 0.0  # Temps total d'affliction (peut être négatif = buff)
var is_buffed: bool = false

# Références
@onready var visual_root = $VisualRoot
@onready var mesh = $VisualRoot/MeshInstance3D
@onready var collision = $CollisionShape3D
@onready var debuff_timer = $DebuffTimer

# Détection d'esquive
var dodge_detector: Area3D

# Durées des débuffs (en secondes)
const DEBUFF_DURATIONS = {
	"lent": 5.0,
	"nul": 4.0,
	"fragile": 6.0,
	"aveugle": 3.0,
	"confus": 4.0
}

func _ready():
	# Initialiser la position du joueur au centre (Y=0.5 pour être sur le sol)
	position = Vector3(0, 0.5, 0)

	# Créer la zone de détection d'esquive programmatiquement
	setup_dodge_detector()

	# Charger la scène du projectile 3D (elle devra être convertie aussi)
	bullet_scene = preload("res://scenes/game/player_bullet.tscn")

	# Émettre les signaux initiaux
	emit_signal("health_changed", health, max_health)
	emit_signal("ammo_changed", current_ammo, max_ammo, is_reloading)
	emit_signal("blanks_changed", blanks)

func _process(delta):
	# Gestion du cooldown de dodge
	if dodge_cooldown_timer > 0:
		dodge_cooldown_timer -= delta

	# Gestion du rechargement
	if is_reloading:
		reload_timer -= delta
		if reload_timer <= 0:
			complete_reload()

	# Mettre à jour le temps d'affliction
	if affliction_time > 0:
		affliction_time -= delta
		if affliction_time <= 0:
			affliction_time = 0
			clear_all_debuffs()
		emit_signal("affliction_changed", affliction_time)
	elif affliction_time < 0:
		# En buff positif
		affliction_time += delta
		if affliction_time >= 0:
			affliction_time = 0
			remove_buff()
		emit_signal("affliction_changed", affliction_time)

	# Gestion du tir
	handle_shooting(delta)

	# Gestion de l'immunité émotionnelle
	if is_emotionally_immune:
		immunity_timer -= delta
		if immunity_timer <= 0:
			end_emotional_immunity()
		else:
			emit_signal("confidence_changed", confidence, is_emotionally_immune, immunity_timer)

	# Reset du combo d'esquive si timeout
	if dodge_combo > 0 and (Time.get_ticks_msec() / 1000.0 - last_dodge_time) > DODGE_COMBO_TIMEOUT:
		dodge_combo = 0

	# Gestion du blank
	if Input.is_action_just_pressed("blank") and blanks > 0:
		use_blank()

func _physics_process(delta):
	# Visée 360° vers la souris (intersection avec le plan XZ)
	if current_state != State.DODGING:
		look_at_mouse()

	handle_movement(delta)
	move_and_slide()

func look_at_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	if not camera: return

	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)

	# Intersection avec le plan horizontal Y=0.5
	var t = (0.5 - ray_origin.y) / ray_direction.y
	var target = ray_origin + ray_direction * t

	look_at(Vector3(target.x, position.y, target.z), Vector3.UP)

func setup_dodge_detector():
	dodge_detector = Area3D.new()
	var shape = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 4.0 # Rayon d'esquive en 3D
	shape.shape = sphere
	dodge_detector.add_child(shape)
	add_child(dodge_detector)
	dodge_detector.area_exited.connect(_on_dodge_area_exited)

func _on_dodge_area_exited(area):
	if area.has_method("set_as_dodged"):
		area.set_as_dodged()

func handle_movement(delta):
	if current_state == State.DODGING:
		dodge_timer -= delta
		velocity = dodge_direction * dodge_speed
		if dodge_timer <= 0:
			end_dodge()
		return

	# Mouvement 3D sur le plan XZ
	var input_vec = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var move_dir = Vector3(input_vec.x, 0, input_vec.y)

	# Gérer le déclenchement du dodge
	if Input.is_action_just_pressed("dodge") and dodge_cooldown_timer <= 0 and move_dir != Vector3.ZERO:
		start_dodge(move_dir)
		return

	# Appliquer l'inversion si le débuff "confus" est actif
	if inverted_controls:
		move_dir = -move_dir

	# Appliquer le mouvement
	velocity = move_dir * current_speed

func start_dodge(direction: Vector3):
	current_state = State.DODGING
	dodge_direction = direction.normalized()
	dodge_timer = dodge_duration
	dodge_cooldown_timer = dodge_cooldown

	# Invincibilité pendant le dodge
	invincible = true

	# Effet visuel
	if mesh:
		mesh.transparency = 0.5

func end_dodge():
	if is_emotionally_immune:
		current_state = State.IMMUNE
	else:
		current_state = State.NORMAL

	invincible = false
	if mesh:
		mesh.transparency = 0.0

func apply_debuff(debuff_type: String):
	# Si en train de dodger ou immunité émotionnelle active, ignorer le débuff
	if current_state == State.DODGING or is_emotionally_immune:
		on_comment_dodged()
		# Flash visuel
		return

	emit_signal("hit_by_comment", debuff_type)

	modify_confidence(-CONFIDENCE_HIT_LOSS)

	var debuff_duration = DEBUFF_DURATIONS[debuff_type]
	affliction_time += debuff_duration
	emit_signal("affliction_changed", affliction_time)

	if active_debuffs.has(debuff_type):
		active_debuffs[debuff_type].time_left = debuff_duration
		return

	var timer = Timer.new()
	timer.wait_time = debuff_duration
	timer.one_shot = true
	timer.timeout.connect(_on_debuff_expired.bind(debuff_type))
	add_child(timer)
	timer.start()

	active_debuffs[debuff_type] = timer

	# Appliquer l'effet du débuff
	match debuff_type:
		"lent":
			current_speed = BASE_SPEED * 0.5
		"nul":
			if mesh:
				mesh.scale = Vector3(0.7, 0.7, 0.7)
		"fragile":
			if collision:
				collision.scale = Vector3(1.5, 1.5, 1.5)
		"aveugle":
			reduced_visibility = true
		"confus":
			inverted_controls = true

	emit_signal("debuff_applied", debuff_type, debuff_duration)

func _on_debuff_expired(debuff_type: String):
	if active_debuffs.has(debuff_type):
		active_debuffs[debuff_type].queue_free()
		active_debuffs.erase(debuff_type)

	# Retirer l'effet du débuff
	match debuff_type:
		"lent":
			if not active_debuffs.has("lent"):
				current_speed = BASE_SPEED
		"nul":
			if not active_debuffs.has("nul") and mesh:
				mesh.scale = Vector3.ONE
		"fragile":
			if not active_debuffs.has("fragile") and collision:
				collision.scale = Vector3.ONE
		"aveugle":
			if not active_debuffs.has("aveugle"):
				reduced_visibility = false
		"confus":
			if not active_debuffs.has("confus"):
				inverted_controls = false

	emit_signal("debuff_expired", debuff_type)

func reset():
	# Réinitialiser tous les débuffs
	for debuff in active_debuffs.values():
		debuff.queue_free()
	active_debuffs.clear()

	current_speed = BASE_SPEED
	if mesh:
		mesh.scale = Vector3.ONE
	inverted_controls = false
	reduced_visibility = false
	if collision:
		collision.scale = Vector3.ONE

	position = Vector3(0, 0.5, 0)
	velocity = Vector3.ZERO
	rotation = Vector3.ZERO

func collect_compliment(healing_time: float):
	emit_signal("compliment_collected", healing_time)
	modify_confidence(CONFIDENCE_COMPLIMENT_GAIN)
	affliction_time -= healing_time
	if affliction_time < 0 and not is_buffed:
		apply_buff()
	emit_signal("affliction_changed", affliction_time)

func apply_buff():
	is_buffed = true
	current_speed = BASE_SPEED * BUFF_SPEED_MULTIPLIER

func remove_buff():
	if not is_buffed: return
	is_buffed = false
	current_speed = BASE_SPEED

func clear_all_debuffs():
	for debuff in active_debuffs.keys():
		_on_debuff_expired(debuff)

func handle_shooting(delta):
	if shoot_timer > 0:
		shoot_timer -= delta
		if shoot_timer <= 0:
			can_shoot = true

	if Input.is_action_just_pressed("reload") and not is_reloading and current_ammo < max_ammo:
		start_reload()

	if Input.is_action_pressed("shoot") and can_shoot and not is_reloading:
		if current_ammo > 0:
			shoot()
		else:
			start_reload()

func start_reload():
	if is_reloading: return
	is_reloading = true
	reload_timer = reload_time
	emit_signal("ammo_changed", current_ammo, max_ammo, is_reloading)

func complete_reload():
	is_reloading = false
	current_ammo = max_ammo
	emit_signal("ammo_changed", current_ammo, max_ammo, is_reloading)

func shoot():
	if not bullet_scene: return
	current_ammo -= 1
	emit_signal("ammo_changed", current_ammo, max_ammo, is_reloading)

	var bullet = bullet_scene.instantiate()
	var spread = randf_range(-bullet_spread, bullet_spread)

	# Direction de tir basée sur l'orientation locale (avant = -Z en 3D Godot par convention, mais on utilise look_at donc c'est -Z)
	var shoot_dir = -transform.basis.z.rotated(Vector3.UP, spread)

	bullet.direction = shoot_dir
	if is_emotionally_immune:
		bullet.piercing = true
	get_parent().add_child(bullet)
	bullet.global_position = global_position + shoot_dir * 1.5

	can_shoot = false
	shoot_timer = shoot_cooldown

func is_invincible() -> bool:
	return invincible or current_state == State.DODGING or is_emotionally_immune

func take_damage(amount: int):
	if is_invincible(): return

	# Feedback visuel Flash Rouge
	if mesh:
		var mat = mesh.get_surface_override_material(0)
		if not mat:
			mat = StandardMaterial3D.new()
			mesh.set_surface_override_material(0, mat)
		var old_color = mat.albedo_color
		mat.albedo_color = Color.RED
		var tween = create_tween()
		tween.tween_property(mat, "albedo_color", old_color, 0.2)

	health -= amount
	emit_signal("health_changed", health, max_health)
	modify_confidence(-CONFIDENCE_DAMAGE_LOSS)
	if health <= 0:
		die()
		return
	activate_invincibility()

func activate_invincibility():
	invincible = true
	# Effet de clignotement
	await get_tree().create_timer(invincible_duration).timeout
	invincible = false

func die():
	emit_signal("player_died")

func use_blank():
	blanks -= 1
	emit_signal("blanks_changed", blanks)

	# Nettoyer les projectiles
	var projectiles = get_tree().get_nodes_in_group("comments")
	for p in projectiles:
		if p.global_position.distance_to(global_position) < blank_radius:
			p.queue_free()

	var enemy_bullets = get_tree().get_nodes_in_group("enemy_bullets")
	for b in enemy_bullets:
		if b.global_position.distance_to(global_position) < blank_radius:
			b.queue_free()

	# Repousser les ennemis
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if e.global_position.distance_to(global_position) < 15.0:
			var push_dir = (e.global_position - global_position).normalized()
			if e.has_method("apply_knockback"):
				e.apply_knockback(push_dir * 20.0)

func reset_blanks():
	blanks = max_blanks
	emit_signal("blanks_changed", blanks)

func modify_confidence(amount: float):
	confidence = clamp(confidence + amount, min_confidence, max_confidence)
	if confidence >= max_confidence and not is_emotionally_immune:
		activate_emotional_immunity()
	emit_signal("confidence_changed", confidence, is_emotionally_immune, immunity_timer)

func activate_emotional_immunity():
	is_emotionally_immune = true
	current_state = State.IMMUNE
	immunity_duration = randf_range(IMMUNITY_MIN_DURATION, IMMUNITY_MAX_DURATION)
	immunity_timer = immunity_duration
	current_speed = BASE_SPEED * 1.5
	emit_signal("confidence_changed", confidence, is_emotionally_immune, immunity_timer)

func end_emotional_immunity():
	is_emotionally_immune = false
	current_state = State.NORMAL
	immunity_timer = 0.0
	current_speed = BASE_SPEED
	confidence = 50.0
	emit_signal("confidence_changed", confidence, is_emotionally_immune, immunity_timer)

func on_enemy_killed():
	modify_confidence(CONFIDENCE_KILL_GAIN)
	emit_signal("enemy_killed_by_player")

func on_comment_dodged():
	dodge_combo += 1
	last_dodge_time = Time.get_ticks_msec() / 1000.0
	var confidence_gain = CONFIDENCE_DODGE_GAIN + (dodge_combo * CONFIDENCE_COMBO_BONUS)
	modify_confidence(confidence_gain)
