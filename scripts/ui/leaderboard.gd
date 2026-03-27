extends Control

@onready var wave_selector = $CenterContainer/VBoxContainer/WaveSelector
@onready var best_time_label = $CenterContainer/VBoxContainer/BestTimeLabel
@onready var best_score_label = $CenterContainer/VBoxContainer/BestScoreLabel
@onready var global_high_score_label = $CenterContainer/VBoxContainer/GlobalHighScoreLabel
@onready var waves_completed_label = $CenterContainer/VBoxContainer/WavesCompletedLabel
@onready var back_button = $BackButton

var selected_wave: int = 1

func _ready():
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

	if wave_selector:
		# Remplir le sélecteur avec les vagues complétées
		wave_selector.clear()
		var max_wave = max(GameManager.waves_completed, 1)
		for w in range(1, max_wave + 1):
			wave_selector.add_item("Vague %d" % w, w)
		wave_selector.item_selected.connect(_on_wave_selected)

	if global_high_score_label:
		global_high_score_label.text = "Meilleur Score Global : %d" % GameManager.high_score

	if waves_completed_label:
		waves_completed_label.text = "Vagues Complétées : %d / %d" % [GameManager.waves_completed, GameManager.MAX_WAVES]

	update_wave_display(1)

func update_wave_display(wave: int):
	selected_wave = wave
	var best_time = GameManager.get_wave_best_time(wave)
	var best_score = GameManager.get_wave_best_score(wave)

	if best_time_label:
		if best_time > 0:
			var m = int(best_time) / 60
			var s = int(best_time) % 60
			var c = int(fmod(best_time, 1.0) * 100)
			best_time_label.text = "🥇 Meilleur Temps Vague %d : %02d:%02d.%02d" % [wave, m, s, c]
		else:
			best_time_label.text = "Meilleur Temps Vague %d : --" % wave

	if best_score_label:
		if best_score > 0:
			best_score_label.text = "🏆 Meilleur Score Vague %d : %d" % [wave, best_score]
		else:
			best_score_label.text = "Meilleur Score Vague %d : --" % wave

func _on_wave_selected(index: int):
	var wave = wave_selector.get_item_id(index)
	update_wave_display(wave)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
