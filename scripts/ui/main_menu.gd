extends Control

@onready var play_button = $CenterContainer/VBoxContainer/PlayButton
@onready var level_select_button = $CenterContainer/VBoxContainer/LevelSelectButton
@onready var leaderboard_button = $CenterContainer/VBoxContainer/LeaderboardButton
@onready var settings_button = $CenterContainer/VBoxContainer/SettingsButton
@onready var credits_button = $CenterContainer/VBoxContainer/CreditsButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton
@onready var high_score_label = $HighScoreLabel

func _ready():
	# Connecter les signaux des boutons
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if level_select_button:
		level_select_button.pressed.connect(_on_level_select_pressed)
	if leaderboard_button:
		leaderboard_button.pressed.connect(_on_leaderboard_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if credits_button:
		credits_button.pressed.connect(_on_credits_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

	# Afficher le meilleur score et progression
	update_score_display()

func update_score_display():
	if high_score_label:
		var progress_text = ""
		if GameManager.waves_completed > 0:
			progress_text = "\nProgression : Vague %d / %d" % [GameManager.waves_completed, GameManager.MAX_WAVES]
		high_score_label.text = "Meilleur Score: %d%s" % [GameManager.high_score, progress_text]

func _on_play_pressed():
	# Reprendre depuis la dernière vague ou vague 1
	var start_wave = max(1, GameManager.waves_completed)
	GameManager.start_game(start_wave)
	get_tree().change_scene_to_file("res://scenes/game/game_scene.tscn")

func _on_level_select_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/level_select.tscn")

func _on_leaderboard_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/leaderboard.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/settings_menu.tscn")

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/credits_screen.tscn")

func _on_quit_pressed():
	GameManager.quit_game()
