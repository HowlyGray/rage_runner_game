extends Control

@onready var resume_button = $CenterContainer/VBoxContainer/ResumeButton
@onready var restart_button = $CenterContainer/VBoxContainer/RestartButton
@onready var settings_button = $CenterContainer/VBoxContainer/SettingsButton
@onready var main_menu_button = $CenterContainer/VBoxContainer/MainMenuButton

func _ready():
	# Connecter les signaux
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)

func _input(event):
	if event.is_action_pressed("pause"):
		_on_resume_pressed()

func _on_resume_pressed():
	GameManager.resume_game()
	queue_free()  # Retour au jeu

func _on_restart_pressed():
	GameManager.resume_game()
	GameManager.start_game(GameManager.current_level)
	get_tree().change_scene_to_file("res://scenes/game/game_scene.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/settings_menu.tscn")

func _on_main_menu_pressed():
	GameManager.resume_game()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
