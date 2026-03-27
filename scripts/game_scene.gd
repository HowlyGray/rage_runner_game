extends Node2D

# Références aux nœuds
@onready var player = $Player
@onready var spawner = $CommentSpawner
@onready var hud = $CanvasLayer/HUD
@onready var game_timer_label = $CanvasLayer/HUD/GameTimer
@onready var score_label = $CanvasLayer/HUD/ScoreLabel
@onready var level_label = $CanvasLayer/HUD/LevelLabel
@onready var debuffs_container = $CanvasLayer/HUD/DebuffsContainer
@onready var affliction_bar = $CanvasLayer/HUD/AfflictionBar
@onready var health_display = $CanvasLayer/HUD/HealthDisplay
@onready var confidence_bar = $CanvasLayer/HUD/ConfidenceBar

# Variables de jeu
var game_time: float = 0.0
var level_duration: float = 60.0
var is_game_active: bool = false

func _ready():
	# Connecter les signaux
	GameManager.game_over.connect(_on_game_over)
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.level_changed.connect(_on_level_changed)
	
	if player:
		player.hit_by_comment.connect(_on_player_hit)
		player.debuff_applied.connect(_on_debuff_applied)
		player.debuff_expired.connect(_on_debuff_expired)
		player.compliment_collected.connect(_on_compliment_collected)
		player.affliction_changed.connect(_on_affliction_changed)
		player.health_changed.connect(_on_health_changed)
		player.player_died.connect(_on_player_died)
		player.confidence_changed.connect(_on_confidence_changed)
	
	# Démarrer le jeu
	start_game()

func _process(delta):
	if not is_game_active or GameManager.is_paused:
		return
	
	# Mettre à jour le timer
	game_time += delta
	update_timer_display()
	
	# Vérifier si le niveau est terminé
	if game_time >= level_duration:
		level_completed()

func _input(event):
	if event.is_action_pressed("pause") and is_game_active:
		pause_game()

func start_game():
	# Récupérer la configuration du niveau
	var config = GameManager.get_level_config()
	level_duration = config.duration
	
	# Réinitialiser
	game_time = 0.0
	is_game_active = true
	
	# Réinitialiser le joueur
	if player:
		player.reset()
	
	# Démarrer le spawner
	if spawner:
		spawner.start_spawning()
	
	# Mettre à jour l'UI
	update_ui()

func pause_game():
	GameManager.pause_game()
	get_tree().change_scene_to_file("res://scenes/ui/pause_menu.tscn")

func level_completed():
	is_game_active = false
	
	if spawner:
		spawner.stop_spawning()
		spawner.clear_all_comments()
	
	# Calculer le score bonus (temps restant)
	var time_bonus = int((level_duration - game_time) * 10)
	GameManager.add_score(time_bonus)
	
	# Vérifier s'il y a un niveau suivant
	if GameManager.next_level():
		# Aller au prochain niveau
		get_tree().change_scene_to_file("res://scenes/ui/level_transition.tscn")
	else:
		# Victoire finale
		GameManager.trigger_victory()
		get_tree().change_scene_to_file("res://scenes/ui/victory_screen.tscn")

func update_timer_display():
	if game_timer_label:
		var remaining = level_duration - game_time
		var minutes = int(remaining) / 60
		var seconds = int(remaining) % 60
		game_timer_label.text = "Temps: %02d:%02d" % [minutes, seconds]

func update_ui():
	if score_label:
		score_label.text = "Score: %d" % GameManager.current_score
	
	if level_label:
		level_label.text = "Niveau: %d" % GameManager.current_level

func _on_score_changed(new_score):
	if score_label:
		score_label.text = "Score: %d" % new_score

func _on_level_changed(new_level):
	if level_label:
		level_label.text = "Niveau: %d" % new_level

func _on_player_hit(debuff_type):
	# Réduire le score quand touché
	GameManager.add_score(-10)

func _on_debuff_applied(debuff_type, duration):
	update_debuffs_display()

func _on_debuff_expired(debuff_type):
	update_debuffs_display()

func update_debuffs_display():
	if not debuffs_container:
		return
	
	# Effacer l'affichage actuel
	for child in debuffs_container.get_children():
		child.queue_free()
	
	# Afficher les débuffs actifs
	if player:
		var active_debuffs = player.get_active_debuffs()
		for debuff in active_debuffs:
			var label = Label.new()
			label.text = debuff.to_upper()
			label.add_theme_color_override("font_color", Color.RED)
			debuffs_container.add_child(label)

func _on_game_over():
	is_game_active = false
	if spawner:
		spawner.stop_spawning()
	get_tree().change_scene_to_file("res://scenes/ui/game_over_screen.tscn")

func _on_compliment_collected(healing_time):
	# Bonus de points pour avoir ramassé un compliment
	GameManager.add_score(20)

func _on_affliction_changed(affliction_time):
	if affliction_bar:
		affliction_bar.update_affliction(affliction_time)

func _on_health_changed(current_health, max_health):
	if health_display:
		health_display.update_health(current_health, max_health)

func _on_player_died():
	is_game_active = false
	GameManager.trigger_game_over()

func _on_confidence_changed(confidence_value, is_immune, immunity_time):
	if confidence_bar:
		confidence_bar.update_confidence(confidence_value, is_immune, immunity_time)
