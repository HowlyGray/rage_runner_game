extends CharacterBody2D

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
const BASE_SPEED = 400.0
const BASE_SCALE = Vector2(1.0, 1.0)
const BUFF_SPEED_MULTIPLIER = 1.3  # +30% de vitesse en buff

# Variables de mouvement
var current_speed: float = BASE_SPEED
var dodge_speed: float = 800.0
var dodge_duration: float = 0.3
var dodge_cooldown: float = 0.6
var dodge_timer: float = 0.0
var dodge_cooldown_timer: float = 0.0
var dodge_direction: Vector2 = Vector2.ZERO

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
var blank_radius: float = 1000.0

# Débuffs actifs
var active_debuffs = {}
var inverted_controls: bool = false
var reduced_visibility: bool = false

# Système d'affliction
var affliction_time: float = 0.0  # Temps total d'affliction (peut être négatif = buff)
var is_buffed: bool = false

# Références
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var debuff_timer = $DebuffTimer

# Détection d'esquive
var dodge_detector: Area2D

# Durées des débuffs (en secondes)
const DEBUFF_DURATIONS = {
	"lent": 5.0,
	"nul": 4.0,
	"fragile": 6.0,
	"aveugle": 3.0,
	"confus": 4.0
}

func _ready():
	# Initialiser la position du joueur au centre
	position = Vector2(640, 360)

	# Créer la zone de détection d'esquive programmatiquement
	setup_dodge_detector()

	# Charger la scène du projectile
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
	# Toujours pointer vers la souris (visée 360°) sauf pendant le dodge
	if current_state != State.DODGING:
		look_at(get_global_mouse_position())

	handle_movement(delta)
	move_and_slide()

func setup_dodge_detector():
	dodge_detector = Area2D.new()
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 100.0
	shape.shape = circle
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

	# Mouvement 2D complet (WASD / ZQSD / Flèches)
	var input_vec = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Gérer le déclenchement du dodge
	if Input.is_action_just_pressed("dodge") and dodge_cooldown_timer <= 0 and input_vec != Vector2.ZERO:
		start_dodge(input_vec)
		return

	# Appliquer l'inversion si le débuff "confus" est actif
	if inverted_controls:
		input_vec = -input_vec

	# Appliquer le mouvement (les murs StaticBody2D gèrent les limites de l'arène)
	velocity = input_vec * current_speed

func start_dodge(direction: Vector2):
	current_state = State.DODGING
	dodge_direction = direction.normalized()
	dodge_timer = dodge_duration
	dodge_cooldown_timer = dodge_cooldown

	# Invincibilité pendant le dodge
	invincible = true

	# Effet visuel (inclinaison ou traînée peut être ajouté plus tard)
	if sprite:
		sprite.modulate.a = 0.5

func end_dodge():
	if is_emotionally_immune:
		current_state = State.IMMUNE
	else:
		current_state = State.NORMAL

	invincible = false
	if sprite:
		sprite.modulate.a = 1.0

func apply_debuff(debuff_type: String):
	# Si en train de dodger ou immunité émotionnelle active, ignorer le débuff
	if current_state == State.DODGING or is_emotionally_immune:
		# Optionnel : déclencher on_comment_dodged si c'est un "close call"
		# Mais ici on a été touché, donc c'est une esquive de justesse
		on_comment_dodged()

		# Effet visuel pour montrer l'esquive/immunité
		if sprite:
			var tween = create_tween()
			tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 0.0), 0.1)
			tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0), 0.1)
		return

	emit_signal("hit_by_comment", debuff_type)

	# Réduire la confiance
	modify_confidence(-CONFIDENCE_HIT_LOSS)

	# Ajouter le temps d'affliction
	var debuff_duration = DEBUFF_DURATIONS[debuff_type]
	affliction_time += debuff_duration
	emit_signal("affliction_changed", affliction_time)

	# Si le débuff est déjà actif, réinitialiser le timer
	if active_debuffs.has(debuff_type):
		active_debuffs[debuff_type].time_left = debuff_duration
		return

	# Créer un nouveau timer pour ce débuff
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
			scale = BASE_SCALE * 0.7
		"fragile":
			if collision:
				collision.scale = Vector2(1.5, 1.5)
		"aveugle":
			reduced_visibility = true
			if sprite:
				sprite.modulate.a = 0.5
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
			if not active_debuffs.has("nul"):
				scale = BASE_SCALE
		"fragile":
			if not active_debuffs.has("fragile") and collision:
				collision.scale = Vector2(1.0, 1.0)
		"aveugle":
			if not active_debuffs.has("aveugle"):
				reduced_visibility = false
				if sprite:
					sprite.modulate.a = 1.0
		"confus":
			if not active_debuffs.has("confus"):
				inverted_controls = false

	emit_signal("debuff_expired", debuff_type)

func reset():
	# Réinitialiser tous les débuffs
	for debuff in active_debuffs.values():
		debuff.queue_free()
	active_debuffs.clear()

	# Réinitialiser les stats
	current_speed = BASE_SPEED
	scale = BASE_SCALE
	inverted_controls = false
	reduced_visibility = false
	if collision:
		collision.scale = Vector2(1.0, 1.0)
	if sprite:
		sprite.modulate = Color(1.0, 1.0, 1.0)

	# Réinitialiser la position au centre de l'arène
	position = Vector2(640, 360)
	velocity = Vector2.ZERO
	rotation = 0.0

func get_active_debuffs() -> Array:
	return active_debuffs.keys()

func collect_compliment(healing_time: float):
	emit_signal("compliment_collected", healing_time)

	# Augmenter la confiance
	modify_confidence(CONFIDENCE_COMPLIMENT_GAIN)

	# Réduire le temps d'affliction
	affliction_time -= healing_time

	# Si on passe en négatif (buff), appliquer le buff
	if affliction_time < 0 and not is_buffed:
		apply_buff()

	emit_signal("affliction_changed", affliction_time)

func apply_buff():
	is_buffed = true
	# Appliquer les effets positifs
	current_speed = BASE_SPEED * BUFF_SPEED_MULTIPLIER
	if sprite:
		sprite.modulate = Color(0.5, 1.0, 0.5)  # Teinte verte pour le buff

func remove_buff():
	if not is_buffed:
		return
	is_buffed = false
	current_speed = BASE_SPEED
	if sprite:
		sprite.modulate = Color(1.0, 1.0, 1.0)

func clear_all_debuffs():
	# Supprimer tous les débuffs
	for debuff in active_debuffs.keys():
		_on_debuff_expired(debuff)

func get_affliction_time() -> float:
	return affliction_time

func handle_shooting(delta):
	# Cooldown du tir
	if shoot_timer > 0:
		shoot_timer -= delta
		if shoot_timer <= 0:
			can_shoot = true

	# Gérer le rechargement manuel
	if Input.is_action_just_pressed("reload") and not is_reloading and current_ammo < max_ammo:
		start_reload()

	# Auto-fire : LMB maintenu ou ESPACE maintenu
	if Input.is_action_pressed("shoot") and can_shoot and not is_reloading:
		if current_ammo > 0:
			shoot()
		else:
			start_reload()

func start_reload():
	if is_reloading:
		return
	is_reloading = true
	reload_timer = reload_time
	emit_signal("ammo_changed", current_ammo, max_ammo, is_reloading)

func complete_reload():
	is_reloading = false
	current_ammo = max_ammo
	emit_signal("ammo_changed", current_ammo, max_ammo, is_reloading)

func shoot():
	if not bullet_scene:
		return

	current_ammo -= 1
	emit_signal("ammo_changed", current_ammo, max_ammo, is_reloading)

	# Créer un projectile dans la direction visée avec un peu de spread
	var bullet = bullet_scene.instantiate()

	# Appliquer le spread
	var spread = randf_range(-bullet_spread, bullet_spread)
	var shoot_dir = transform.x.rotated(spread)

	bullet.global_position = global_position + shoot_dir * 35.0
	bullet.direction = shoot_dir

	# En mode IMMUNE (immunité émotionnelle), les balles sont perçantes
	if is_emotionally_immune:
		bullet.piercing = true

	# Ajouter à la scène parente
	get_parent().add_child(bullet)

	# Activer le cooldown
	can_shoot = false
	shoot_timer = shoot_cooldown


func is_invincible() -> bool:
	return invincible or current_state == State.DODGING or is_emotionally_immune

func take_damage(amount: int):
	if is_invincible():
		return

	# Flash rouge sur les dégâts
	if sprite:
		var tween = create_tween()
		sprite.modulate = Color.RED
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)

	health -= amount
	emit_signal("health_changed", health, max_health)

	# Réduire la confiance
	modify_confidence(-CONFIDENCE_DAMAGE_LOSS)

	# Vérifier la mort
	if health <= 0:
		die()
		return

	# Activer l'invincibilité temporaire
	activate_invincibility()

func activate_invincibility():
	invincible = true

	# Effet visuel de clignotement
	if sprite:
		var tween = create_tween()
		tween.set_loops(int(invincible_duration / 0.2))
		tween.tween_property(sprite, "modulate:a", 0.3, 0.1)
		tween.tween_property(sprite, "modulate:a", 1.0, 0.1)

	# Timer pour retirer l'invincibilité
	await get_tree().create_timer(invincible_duration).timeout
	invincible = false
	if sprite:
		sprite.modulate.a = 1.0

func die():
	emit_signal("player_died")
	# Ne pas détruire le joueur, laisser game_scene gérer le game over

func heal(amount: int):
	health = min(health + amount, max_health)
	emit_signal("health_changed", health, max_health)

func use_blank():
	blanks -= 1
	emit_signal("blanks_changed", blanks)

	# Effet visuel
	var flash = ColorRect.new()
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.color = Color(1, 1, 1, 0.5)
	get_tree().root.add_child(flash)

	var tween = create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.3)
	tween.tween_callback(flash.queue_free)

	# Nettoyer les projectiles (commentaires et balles ennemies)
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
		if e.global_position.distance_to(global_position) < 400.0:
			var push_dir = e.global_position.direction_to(global_position) * -1.0
			var push_tween = create_tween()
			push_tween.tween_property(e, "global_position", e.global_position + push_dir * 200.0, 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func reset_blanks():
	blanks = max_blanks
	emit_signal("blanks_changed", blanks)

# === SYSTÈME DE CONFIANCE ===

func modify_confidence(amount: float):
	confidence = clamp(confidence + amount, min_confidence, max_confidence)

	# Si on atteint 100%, activer l'immunité émotionnelle
	if confidence >= max_confidence and not is_emotionally_immune:
		activate_emotional_immunity()

	emit_signal("confidence_changed", confidence, is_emotionally_immune, immunity_timer)

func activate_emotional_immunity():
	is_emotionally_immune = true
	current_state = State.IMMUNE

	# Durée aléatoire entre min et max
	immunity_duration = randf_range(IMMUNITY_MIN_DURATION, IMMUNITY_MAX_DURATION)
	immunity_timer = immunity_duration

	# Effet visuel (teinte dorée) + bonus de vitesse
	if sprite:
		sprite.modulate = Color(1.0, 0.9, 0.0)
	current_speed = BASE_SPEED * 1.5

	emit_signal("confidence_changed", confidence, is_emotionally_immune, immunity_timer)

func end_emotional_immunity():
	is_emotionally_immune = false
	current_state = State.NORMAL
	immunity_timer = 0.0

	# Retirer le bonus de vitesse
	current_speed = BASE_SPEED

	# Retirer l'effet visuel
	if sprite and not is_buffed:
		sprite.modulate = Color(1.0, 1.0, 1.0)
	elif sprite and is_buffed:
		sprite.modulate = Color(0.5, 1.0, 0.5)  # Remettre la teinte de buff

	# Réinitialiser la confiance à 50%
	confidence = 50.0

	emit_signal("confidence_changed", confidence, is_emotionally_immune, immunity_timer)

func on_enemy_killed():
	# Augmenter la confiance
	modify_confidence(CONFIDENCE_KILL_GAIN)
	emit_signal("enemy_killed_by_player")

func on_comment_dodged():
	# Augmenter le combo
	dodge_combo += 1
	last_dodge_time = Time.get_ticks_msec() / 1000.0

	# Gain de confiance de base + bonus combo
	var confidence_gain = CONFIDENCE_DODGE_GAIN + (dodge_combo * CONFIDENCE_COMBO_BONUS)
	modify_confidence(confidence_gain)

func reset_confidence():
	confidence = 50.0
	is_emotionally_immune = false
	immunity_timer = 0.0
	current_state = State.NORMAL
	current_speed = BASE_SPEED
	dodge_combo = 0
	emit_signal("confidence_changed", confidence, is_emotionally_immune, immunity_timer)
