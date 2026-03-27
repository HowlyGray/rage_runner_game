extends Control

@onready var levels_container = $CenterContainer/VBoxContainer/LevelsGrid
@onready var back_button = $BackButton
@onready var title_label = $Title

func _ready():
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

	if title_label:
		title_label.text = "SÉLECTION VAGUE\n(Débloquées jusqu'à vague %d)" % (GameManager.waves_completed + 1)

	setup_wave_buttons()

func setup_wave_buttons():
	if not levels_container:
		return

	# Afficher les vagues par groupes de 10
	# Les vagues débloquées sont celles jusqu'à waves_completed + 1
	var max_unlocked = GameManager.waves_completed + 1

	for wave in range(1, GameManager.MAX_WAVES + 1):
		var button = Button.new()
		var best_score = GameManager.get_wave_best_score(wave)
		var best_time = GameManager.get_wave_best_time(wave)

		if wave <= max_unlocked:
			# Vague débloquée
			if best_score > 0:
				button.text = "V%d\n%d pts" % [wave, best_score]
			else:
				button.text = "Vague %d" % wave
			button.custom_minimum_size = Vector2(100, 70)
			button.pressed.connect(_on_wave_selected.bind(wave))

			# Tooltip avec le meilleur temps
			if best_time > 0:
				var m = int(best_time) / 60
				var s = int(best_time) % 60
				button.tooltip_text = "Meilleur temps : %02d:%02d\nMeilleur score : %d" % [m, s, best_score]
			else:
				var config = GameManager.get_wave_config(wave)
				var difficulty = get_difficulty_text(wave)
				button.tooltip_text = "Ennemis : %d\nDifficulté : %s" % [config.enemy_count, difficulty]
		else:
			# Vague verrouillée
			button.text = "🔒 %d" % wave
			button.custom_minimum_size = Vector2(100, 70)
			button.disabled = true
			button.modulate = Color(0.5, 0.5, 0.5, 0.7)

		levels_container.add_child(button)

func get_difficulty_text(wave: int) -> String:
	if wave <= 10:
		return "Débutant"
	elif wave <= 25:
		return "Facile"
	elif wave <= 50:
		return "Moyen"
	elif wave <= 75:
		return "Difficile"
	elif wave <= 90:
		return "Expert"
	else:
		return "Légendaire"

func _on_wave_selected(wave: int):
	GameManager.start_game(wave)
	get_tree().change_scene_to_file("res://scenes/game/game_scene.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
