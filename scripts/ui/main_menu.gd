extends Control

@onready var play_button = $CenterContainer/VBoxContainer/PlayButton
@onready var level_select_button = $CenterContainer/VBoxContainer/LevelSelectButton
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
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if credits_button:
		credits_button.pressed.connect(_on_credits_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	
	# Afficher le meilleur score
	update_high_score()

func update_high_score():
	if high_score_label:
		high_score_label.text = "Meilleur Score: %d" % GameManager.high_score

func _on_play_pressed():
	GameManager.start_game(1)
	get_tree().change_scene_to_file("res://scenes/game/game_scene.tscn")

func _on_level_select_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/level_select.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/settings_menu.tscn")

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/credits_screen.tscn")

func _on_quit_pressed():
	GameManager.quit_game()
