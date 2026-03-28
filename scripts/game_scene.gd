extends Node3D

# Références aux nœuds
@onready var player = $Player
@onready var spawner = $CommentSpawner
@onready var camera = $Camera3D
@onready var hud = $CanvasLayer/HUD
@onready var enemies_label = $CanvasLayer/HUD/GameTimer
@onready var score_label = $CanvasLayer/HUD/ScoreLabel
@onready var level_label = $CanvasLayer/HUD/LevelLabel
@onready var debuffs_container = $CanvasLayer/HUD/DebuffsContainer
@onready var affliction_bar = $CanvasLayer/HUD/AfflictionBar
@onready var health_display = $CanvasLayer/HUD/HealthDisplay
@onready var confidence_bar = $CanvasLayer/HUD/ConfidenceBar
@onready var ammo_label = $CanvasLayer/HUD/AmmoLabel
@onready var blanks_label = $CanvasLayer/HUD/BlanksLabel

# Variables de vague
var current_wave: int = 1
var enemies_remaining: int = 0
var enemies_killed_this_wave: int = 0
var wave_start_time: float = 0.0
var is_game_active: bool = false

func _ready():
	if camera and not camera.get_script():
		camera.set_script(load("res://scripts/camera.gd"))

	GameManager.game_over.connect(_on_game_over)
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.wave_changed.connect(_on_wave_changed)

	if player:
		player.hit_by_comment.connect(_on_player_hit)
		player.debuff_applied.connect(_on_debuff_applied)
		player.debuff_expired.connect(_on_debuff_expired)
		player.compliment_collected.connect(_on_compliment_collected)
		player.affliction_changed.connect(_on_affliction_changed)
		player.health_changed.connect(_on_health_changed)
		player.player_died.connect(_on_player_died)
		player.confidence_changed.connect(_on_confidence_changed)
		player.ammo_changed.connect(_on_ammo_changed)
		player.blanks_changed.connect(_on_blanks_changed)

	current_wave = GameManager.current_wave
	start_wave(current_wave)

func _process(_delta):
	if not is_game_active or GameManager.is_paused:
		return

	if camera and player:
		# Caméra suit le joueur en 3D avec un offset fixe
		var target_pos = player.global_position + Vector3(0, 30, 15)
		camera.global_position = camera.global_position.lerp(target_pos, 0.1)
		camera.look_at(player.global_position, Vector3.UP)

	update_enemies_display()

func _input(event):
	if event.is_action_pressed("pause") and is_game_active:
		pause_game()

func start_wave(wave_num: int):
	current_wave = wave_num
	is_game_active = true
	enemies_killed_this_wave = 0
	wave_start_time = Time.get_ticks_msec() / 1000.0

	var config = GameManager.get_wave_config(wave_num)
	enemies_remaining = config.enemy_count

	if player:
		player.position = Vector3(0, 0.5, 0)
		player.velocity = Vector3.ZERO
		player.rotation = Vector3.ZERO
		player.reset_blanks()

	if spawner:
		spawner.configure_wave(config)
		spawner.start_wave_spawning(config.enemy_count)

	update_ui()

func on_enemy_died():
	enemies_remaining -= 1
	enemies_killed_this_wave += 1
	update_enemies_display()
	if enemies_remaining <= 0:
		wave_completed()

func wave_completed():
	is_game_active = false
	if spawner: spawner.stop_spawning()
	var elapsed = (Time.get_ticks_msec() / 1000.0) - wave_start_time
	var wave_score = calculate_wave_score(elapsed)
	GameManager.add_score(wave_score)
	GameManager.save_wave_result(current_wave, elapsed, wave_score)
	GameManager.set_meta("last_wave", current_wave)
	GameManager.set_meta("last_wave_time", elapsed)
	GameManager.set_meta("last_wave_score", wave_score)
	get_tree().change_scene_to_file("res://scenes/ui/wave_intermission.tscn")

func calculate_wave_score(elapsed_time: float) -> int:
	var config = GameManager.get_wave_config(current_wave)
	var base = config.enemy_count * 100
	var time_bonus = max(0, int((120.0 - elapsed_time) * 20))
	var confidence_bonus = int(player.confidence * 10) if player else 0
	return base + time_bonus + confidence_bonus

func pause_game():
	GameManager.pause_game()
	get_tree().change_scene_to_file("res://scenes/ui/pause_menu.tscn")

func update_enemies_display():
	if enemies_label:
		enemies_label.text = "Ennemis: %d" % enemies_remaining

func update_ui():
	if score_label: score_label.text = "Score: %d" % GameManager.current_score
	if level_label: level_label.text = "Vague: %d / %d" % [current_wave, GameManager.MAX_WAVES]
	update_enemies_display()

func _on_score_changed(new_score):
	if score_label: score_label.text = "Score: %d" % new_score

func _on_wave_changed(new_wave):
	if level_label: level_label.text = "Vague: %d / %d" % [new_wave, GameManager.MAX_WAVES]

func _on_player_hit(_debuff_type):
	GameManager.add_score(-10)
	if camera and camera.has_method("add_shake"):
		camera.add_shake(10.0)
	trigger_hit_stop(0.1, 0.1)

func trigger_hit_stop(time_scale: float, duration: float):
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = 1.0

func _on_debuff_applied(_debuff_type, _duration):
	update_debuffs_display()

func _on_debuff_expired(_debuff_type):
	update_debuffs_display()

func update_debuffs_display():
	if not debuffs_container: return
	for child in debuffs_container.get_children(): child.queue_free()
	if player:
		var active_debuffs = player.active_debuffs.keys()
		for debuff in active_debuffs:
			var label = Label.new()
			label.text = debuff.to_upper()
			label.add_theme_color_override("font_color", Color.RED)
			debuffs_container.add_child(label)

func _on_game_over():
	is_game_active = false
	if spawner: spawner.stop_spawning()
	get_tree().change_scene_to_file("res://scenes/ui/game_over_screen.tscn")

func _on_compliment_collected(_healing_time):
	GameManager.add_score(20)

func _on_affliction_changed(affliction_time):
	if affliction_bar: affliction_bar.update_affliction(affliction_time)

func _on_health_changed(current_health, max_health):
	if health_display: health_display.update_health(current_health, max_health)
	if camera and camera.has_method("add_shake"): camera.add_shake(20.0)
	trigger_hit_stop(0.05, 0.2)

func _on_player_died():
	is_game_active = false
	GameManager.trigger_game_over()

func _on_confidence_changed(confidence_value, is_immune, immunity_time):
	if confidence_bar: confidence_bar.update_confidence(confidence_value, is_immune, immunity_time)

func _on_ammo_changed(current_ammo, max_ammo, is_reloading):
	if ammo_label:
		if is_reloading:
			ammo_label.text = "RECHARGEMENT..."
			ammo_label.modulate = Color.YELLOW
		else:
			ammo_label.text = "MUN: %d / %d" % [current_ammo, max_ammo]
			ammo_label.modulate = Color.RED if current_ammo == 0 else Color.WHITE

func _on_blanks_changed(blanks_remaining):
	if blanks_label:
		blanks_label.text = "BLANKS: %d" % blanks_remaining
		blanks_label.modulate = Color.GRAY if blanks_remaining == 0 else Color.CYAN
