extends Control

@onready var levels_container = $CenterContainer/VBoxContainer/LevelsGrid
@onready var back_button = $BackButton

func _ready():
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	setup_level_buttons()

func setup_level_buttons():
	if not levels_container:
		return
	
	# Créer un bouton pour chaque niveau
	for level in range(1, GameManager.max_level + 1):
		var button = Button.new()
		button.text = "Niveau %d" % level
		button.custom_minimum_size = Vector2(200, 80)
		
		# Ajouter des informations sur le niveau
		var config = GameManager.get_level_config(level)
		var duration = config.duration
		var minutes = duration / 60
		
		button.tooltip_text = "Durée: %d min\nDifficulté: %s" % [minutes, get_difficulty_text(level)]
		
		# Connecter le signal
		button.pressed.connect(_on_level_selected.bind(level))
		
		# Ajouter au conteneur
		levels_container.add_child(button)

func get_difficulty_text(level: int) -> String:
	match level:
		1:
			return "Facile"
		2:
			return "Moyen"
		3:
			return "Difficile"
		4:
			return "Très Difficile"
		5:
			return "Extrême"
		_:
			return "Inconnu"

func _on_level_selected(level: int):
	GameManager.start_game(level)
	get_tree().change_scene_to_file("res://scenes/game/game_scene.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
