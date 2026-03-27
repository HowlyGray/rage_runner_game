extends Control

@onready var final_score_label = $CenterContainer/VBoxContainer/FinalScoreLabel
@onready var high_score_label = $CenterContainer/VBoxContainer/HighScoreLabel
@onready var retry_button = $CenterContainer/VBoxContainer/RetryButton
@onready var main_menu_button = $CenterContainer/VBoxContainer/MainMenuButton

func _ready():
	# Connecter les signaux
	if retry_button:
		retry_button.pressed.connect(_on_retry_pressed)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# Afficher les scores
	update_score_display()

func update_score_display():
	if final_score_label:
		final_score_label.text = "Score Final: %d" % GameManager.current_score
	
	if high_score_label:
		if GameManager.current_score >= GameManager.high_score:
			high_score_label.text = "NOUVEAU RECORD! 🏆"
			high_score_label.add_theme_color_override("font_color", Color.GOLD)
		else:
			high_score_label.text = "Meilleur Score: %d" % GameManager.high_score

func _on_retry_pressed():
	GameManager.start_game(GameManager.current_level)
	get_tree().change_scene_to_file("res://scenes/game/game_scene.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
