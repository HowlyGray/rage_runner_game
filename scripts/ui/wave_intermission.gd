extends Control

@onready var wave_label = $CenterContainer/VBoxContainer/WaveLabel
@onready var time_label = $CenterContainer/VBoxContainer/TimeLabel
@onready var wave_score_label = $CenterContainer/VBoxContainer/WaveScoreLabel
@onready var total_score_label = $CenterContainer/VBoxContainer/TotalScoreLabel
@onready var best_time_label = $CenterContainer/VBoxContainer/BestTimeLabel
@onready var health_label = $CenterContainer/VBoxContainer/HealthLabel
@onready var next_button = $CenterContainer/VBoxContainer/NextButton
@onready var menu_button = $CenterContainer/VBoxContainer/MenuButton

func _ready():
	# Récupérer les données de la vague terminée
	var wave_num = GameManager.get_meta("last_wave", 1)
	var elapsed = GameManager.get_meta("last_wave_time", 0.0)
	var wave_score = GameManager.get_meta("last_wave_score", 0)

	# Afficher les informations
	if wave_label:
		wave_label.text = "Vague %d terminée !" % wave_num

	if time_label:
		var minutes = int(elapsed) / 60
		var seconds = int(elapsed) % 60
		var centisecs = int(fmod(elapsed, 1.0) * 100)
		time_label.text = "Temps : %02d:%02d.%02d" % [minutes, seconds, centisecs]

	if wave_score_label:
		wave_score_label.text = "Points gagnés : +%d" % wave_score

	if total_score_label:
		total_score_label.text = "Score total : %d" % GameManager.current_score

	# Afficher le meilleur temps pour cette vague
	if best_time_label:
		var best = GameManager.get_wave_best_time(wave_num)
		if best > 0:
			var bm = int(best) / 60
			var bs = int(best) % 60
			var bc = int(fmod(best, 1.0) * 100)
			best_time_label.text = "Meilleur temps : %02d:%02d.%02d" % [bm, bs, bc]
		else:
			best_time_label.text = "Meilleur temps : --:--"

	# Ne PAS afficher la santé actuelle du joueur (pour souligner qu'elle n'est pas restaurée)
	if health_label:
		health_label.text = "⚠ La santé n'est pas restaurée entre les vagues !"
		health_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0))

	# Connecter les boutons
	if next_button:
		next_button.pressed.connect(_on_next_pressed)
		# Vérifier si c'est la dernière vague
		var wave = GameManager.get_meta("last_wave", 1)
		if wave >= GameManager.MAX_WAVES:
			next_button.text = "🏆 Voir la Victoire"
		else:
			next_button.text = "Vague %d →" % (wave + 1)

	if menu_button:
		menu_button.pressed.connect(_on_menu_pressed)

func _on_next_pressed():
	var wave = GameManager.get_meta("last_wave", 1)
	if wave >= GameManager.MAX_WAVES:
		# Victoire finale !
		GameManager.trigger_victory()
		get_tree().change_scene_to_file("res://scenes/ui/victory_screen.tscn")
	else:
		# Passer à la vague suivante
		GameManager.next_wave()
		get_tree().change_scene_to_file("res://scenes/game/game_scene.tscn")

func _on_menu_pressed():
	GameManager.save_scores()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
