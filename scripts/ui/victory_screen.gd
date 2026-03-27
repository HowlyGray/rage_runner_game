extends Control

@onready var congratulations_label = $CenterContainer/VBoxContainer/CongratulationsLabel
@onready var final_score_label = $CenterContainer/VBoxContainer/FinalScoreLabel
@onready var high_score_label = $CenterContainer/VBoxContainer/HighScoreLabel
@onready var play_again_button = $CenterContainer/VBoxContainer/PlayAgainButton
@onready var main_menu_button = $CenterContainer/VBoxContainer/MainMenuButton

func _ready():
	# Connecter les signaux
	if play_again_button:
		play_again_button.pressed.connect(_on_play_again_pressed)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# Afficher les scores
	update_display()

func update_display():
	if congratulations_label:
		congratulations_label.text = "🎉 FÉLICITATIONS! 🎉\nVous avez terminé tous les niveaux!"
	
	if final_score_label:
		final_score_label.text = "Score Total: %d" % GameManager.current_score
	
	if high_score_label:
		if GameManager.current_score >= GameManager.high_score:
			high_score_label.text = "NOUVEAU RECORD ABSOLU! 🏆"
			high_score_label.add_theme_color_override("font_color", Color.GOLD)
		else:
			high_score_label.text = "Meilleur Score: %d" % GameManager.high_score

func _on_play_again_pressed():
	GameManager.start_game(1)
	get_tree().change_scene_to_file("res://scenes/game/game_scene.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
