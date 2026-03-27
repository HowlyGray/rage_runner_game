extends Node

# Signaux
signal score_changed(new_score)
signal level_changed(new_level)
signal game_over
signal game_won

# Variables de jeu
var current_score: int = 0
var high_score: int = 0
var current_level: int = 1
var max_level: int = 5
var is_paused: bool = false
var game_time: float = 0.0

# Paramètres de difficulté par niveau
var level_config = {
	1: {"duration": 60, "spawn_rate": 2.0, "comment_speed": 200},
	2: {"duration": 75, "spawn_rate": 1.5, "comment_speed": 250},
	3: {"duration": 90, "spawn_rate": 1.2, "comment_speed": 300},
	4: {"duration": 105, "spawn_rate": 1.0, "comment_speed": 350},
	5: {"duration": 120, "spawn_rate": 0.8, "comment_speed": 400}
}

# Paramètres audio
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 0.8

func _ready():
	load_settings()
	load_high_score()

func start_game(level: int = 1):
	current_level = level
	current_score = 0
	game_time = 0.0
	is_paused = false
	emit_signal("level_changed", current_level)
	emit_signal("score_changed", current_score)

func add_score(points: int):
	current_score += points
	if current_score > high_score:
		high_score = current_score
		save_high_score()
	emit_signal("score_changed", current_score)

func next_level():
	if current_level < max_level:
		current_level += 1
		emit_signal("level_changed", current_level)
		return true
	return false

func get_level_config(level: int = -1):
	if level == -1:
		level = current_level
	return level_config.get(level, level_config[1])

func pause_game():
	is_paused = true
	get_tree().paused = true

func resume_game():
	is_paused = false
	get_tree().paused = false

func trigger_game_over():
	emit_signal("game_over")

func trigger_victory():
	emit_signal("game_won")

func save_high_score():
	var save_file = FileAccess.open("user://highscore.save", FileAccess.WRITE)
	if save_file:
		save_file.store_var(high_score)
		save_file.close()

func load_high_score():
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
			master_volume = settings.get("master_volume", 1.0)
			music_volume = settings.get("music_volume", 0.7)
			sfx_volume = settings.get("sfx_volume", 0.8)
			save_file.close()

func quit_game():
	get_tree().quit()
