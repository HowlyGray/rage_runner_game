extends Node

# Signaux
signal score_changed(new_score)
signal wave_changed(new_wave)
signal game_over
signal game_won

# Variables de jeu
var current_score: int = 0
var high_score: int = 0
var current_wave: int = 1
const MAX_WAVES: int = 99
var is_paused: bool = false

# Données de progression
var waves_completed: int = 0
var wave_best_times: Dictionary = {}   # {"1": float, "2": float, ...}
var wave_best_scores: Dictionary = {}  # {"1": int, "2": int, ...}

# Paramètres audio
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 0.8

func _ready():
	load_settings()
	load_scores()

# === GÉNÉRATION PROCÉDURALE DES VAGUES ===

func get_wave_config(wave: int) -> Dictionary:
	var t = float(wave - 1) / 98.0  # 0.0 (vague 1) → 1.0 (vague 99)
	return {
		"enemy_count": int(lerp(5.0, 40.0, t)),
		"spawn_rate": lerp(2.0, 0.4, t),
		"comment_speed": lerp(200.0, 500.0, t),
		"enemy_speed_mult": lerp(0.8, 1.8, t),
		"brute_ratio": lerp(0.5, 0.3, t),
	}

# Alias de compatibilité pour l'ancien code qui appelait get_level_config()
func get_level_config(level: int = -1) -> Dictionary:
	if level == -1:
		level = current_wave
	return get_wave_config(level)

# === GESTION DE JEU ===

func start_game(wave: int = 1):
	current_wave = wave
	current_score = 0
	is_paused = false
	emit_signal("wave_changed", current_wave)
	emit_signal("score_changed", current_score)

func add_score(points: int):
	current_score += points
	if current_score > high_score:
		high_score = current_score
	emit_signal("score_changed", current_score)

func next_wave():
	if current_wave < MAX_WAVES:
		current_wave += 1
		emit_signal("wave_changed", current_wave)
		return true
	return false

func pause_game():
	is_paused = true
	get_tree().paused = true

func resume_game():
	is_paused = false
	get_tree().paused = false

func trigger_game_over():
	save_scores()
	emit_signal("game_over")

func trigger_victory():
	save_scores()
	emit_signal("game_won")

# === SAUVEGARDE DES SCORES PAR VAGUE ===

func save_wave_result(wave: int, elapsed_time: float, wave_score: int):
	var key = str(wave)

	# Mettre à jour le meilleur temps (plus petit = meilleur)
	if not wave_best_times.has(key) or elapsed_time < wave_best_times[key]:
		wave_best_times[key] = elapsed_time

	# Mettre à jour le meilleur score (plus grand = meilleur)
	if not wave_best_scores.has(key) or wave_score > wave_best_scores[key]:
		wave_best_scores[key] = wave_score

	# Mettre à jour la progression
	if wave > waves_completed:
		waves_completed = wave

	# Mettre à jour le high score global
	if current_score > high_score:
		high_score = current_score

	save_scores()

func get_wave_best_time(wave: int) -> float:
	return wave_best_times.get(str(wave), -1.0)

func get_wave_best_score(wave: int) -> int:
	return wave_best_scores.get(str(wave), -1)

func get_leaderboard_data(wave: int) -> Dictionary:
	return {
		"best_time": get_wave_best_time(wave),
		"best_score": get_wave_best_score(wave),
	}

# === PERSISTANCE ===

func save_scores():
	var data = {
		"global_high_score": high_score,
		"waves_completed": waves_completed,
		"wave_best_times": wave_best_times,
		"wave_best_scores": wave_best_scores,
	}
	var save_file = FileAccess.open("user://scores.save", FileAccess.WRITE)
	if save_file:
		save_file.store_var(data)
		save_file.close()

func load_scores():
	if FileAccess.file_exists("user://scores.save"):
		var save_file = FileAccess.open("user://scores.save", FileAccess.READ)
		if save_file:
			var data = save_file.get_var()
			if data:
				high_score = data.get("global_high_score", 0)
				waves_completed = data.get("waves_completed", 0)
				wave_best_times = data.get("wave_best_times", {})
				wave_best_scores = data.get("wave_best_scores", {})
			save_file.close()
	else:
		# Compatibilité avec l'ancien fichier highscore.save
		load_legacy_high_score()

func load_legacy_high_score():
	if FileAccess.file_exists("user://highscore.save"):
		var save_file = FileAccess.open("user://highscore.save", FileAccess.READ)
		if save_file:
			high_score = save_file.get_var()
			save_file.close()

func save_settings():
	var settings = {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume
	}
	var save_file = FileAccess.open("user://settings.save", FileAccess.WRITE)
	if save_file:
		save_file.store_var(settings)
		save_file.close()

func load_settings():
	if FileAccess.file_exists("user://settings.save"):
		var save_file = FileAccess.open("user://settings.save", FileAccess.READ)
		if save_file:
			var settings = save_file.get_var()
			if settings:
				master_volume = settings.get("master_volume", 1.0)
				music_volume = settings.get("music_volume", 0.7)
				sfx_volume = settings.get("sfx_volume", 0.8)
			save_file.close()

func quit_game():
	get_tree().quit()
