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

# Constantes
const BASE_SPEED = 400.0
const BASE_SCALE = Vector2(1.0, 1.0)
const BUFF_SPEED_MULTIPLIER = 1.3  # +30% de vitesse en buff

# Variables de mouvement
var current_speed: float = BASE_SPEED
var movement_direction: float = 0.0

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

# Système de tir
var can_shoot: bool = true
var shoot_cooldown: float = 0.3
var shoot_timer: float = 0.0
var bullet_scene: PackedScene

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

# Durées des débuffs (en secondes)
const DEBUFF_DURATIONS = {
	"lent": 5.0,
	"nul": 4.0,
	"fragile": 6.0,
	"aveugle": 3.0,
	"confus": 4.0
}

func _ready():
	# Initialiser la position du joueur
	position = Vector2(640, 650)
	
	# Charger la scène du projectile
	bullet_scene = preload("res://scenes/game/player_bullet.tscn")
	
	# Émettre le signal de santé initial
	emit_signal("health_changed", health, max_health)

func _process(delta):
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

func _physics_process(delta):
	handle_movement(delta)
	move_and_slide()

func handle_movement(_delta):
	# Récupérer l'input du joueur
	var input_direction = Input.get_axis("move_left", "move_right")
	
	# Appliquer l'inversion si le débuff "confus" est actif
	if inverted_controls:
		input_direction = -input_direction
	
	# Appliquer le mouvement
	velocity.x = input_direction * current_speed
	
	# Limiter le joueur à l'écran
	position.x = clamp(position.x, 50, 1230)

func apply_debuff(debuff_type: String):
	emit_signal("hit_by_comment", debuff_type)
	
	# Si immunité émotionnelle active, ignorer le débuff
	if is_emotionally_immune:
		# Effet visuel pour montrer l'immunité (optionnel)
		if sprite:
			var tween = create_tween()
			tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 0.0), 0.1)
			tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0), 0.1)
		return  # Ne pas appliquer le débuff
	
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
			# Vérifier si un autre débuff "lent" n'est pas actif
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
		sprite.modulate.a = 1.0
	
	# Réinitialiser la position
	position = Vector2(640, 650)
	velocity = Vector2.ZERO

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
	
	# Tirer si la barre d'espace est pressée
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func shoot():
	if not bullet_scene:
		return
	
	# Créer un projectile
	var bullet = bullet_scene.instantiate()
	bullet.position = position + Vector2(0, -30)  # Au-dessus du joueur
	
	# Ajouter à la scène
	get_parent().add_child(bullet)
	
	# Activer le cooldown
	can_shoot = false
	shoot_timer = shoot_cooldown

func take_damage(amount: int):
	if invincible:
		return
	
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

# === SYSTÈME DE CONFIANCE ===

func modify_confidence(amount: float):
	var old_confidence = confidence
	confidence = clamp(confidence + amount, min_confidence, max_confidence)
	
	# Si on atteint 100%, activer l'immunité émotionnelle
	if confidence >= max_confidence and not is_emotionally_immune:
		activate_emotional_immunity()
	
	emit_signal("confidence_changed", confidence, is_emotionally_immune, immunity_timer)

func activate_emotional_immunity():
	is_emotionally_immune = true
	
	# Durée aléatoire entre min et max
	immunity_duration = randf_range(IMMUNITY_MIN_DURATION, IMMUNITY_MAX_DURATION)
	immunity_timer = immunity_duration
	
	# Effet visuel (teinte dorée)
	if sprite:
		sprite.modulate = Color(1.0, 0.9, 0.0)
	
	emit_signal("confidence_changed", confidence, is_emotionally_immune, immunity_timer)

func end_emotional_immunity():
	is_emotionally_immune = false
	immunity_timer = 0.0
	
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
	dodge_combo = 0
	emit_signal("confidence_changed", confidence, is_emotionally_immune, immunity_timer)
