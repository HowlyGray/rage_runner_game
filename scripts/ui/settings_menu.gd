extends Control

@onready var master_slider = $CenterContainer/VBoxContainer/MasterVolume/HSlider
@onready var music_slider = $CenterContainer/VBoxContainer/MusicVolume/HSlider
@onready var sfx_slider = $CenterContainer/VBoxContainer/SFXVolume/HSlider
@onready var back_button = $BackButton

@onready var master_value_label = $CenterContainer/VBoxContainer/MasterVolume/ValueLabel
@onready var music_value_label = $CenterContainer/VBoxContainer/MusicVolume/ValueLabel
@onready var sfx_value_label = $CenterContainer/VBoxContainer/SFXVolume/ValueLabel

func _ready():
	# Charger les valeurs actuelles
	if master_slider:
		master_slider.value = GameManager.master_volume * 100
		master_slider.value_changed.connect(_on_master_volume_changed)
	
	if music_slider:
		music_slider.value = GameManager.music_volume * 100
		music_slider.value_changed.connect(_on_music_volume_changed)
	
	if sfx_slider:
		sfx_slider.value = GameManager.sfx_volume * 100
		sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	update_value_labels()

func update_value_labels():
	if master_value_label:
		master_value_label.text = "%d%%" % (GameManager.master_volume * 100)
	if music_value_label:
		music_value_label.text = "%d%%" % (GameManager.music_volume * 100)
	if sfx_value_label:
		sfx_value_label.text = "%d%%" % (GameManager.sfx_volume * 100)

func _on_master_volume_changed(value):
	GameManager.master_volume = value / 100.0
	AudioManager.update_volumes()
	update_value_labels()

func _on_music_volume_changed(value):
	GameManager.music_volume = value / 100.0
	AudioManager.update_volumes()
	update_value_labels()

func _on_sfx_volume_changed(value):
	GameManager.sfx_volume = value / 100.0
	AudioManager.update_volumes()
	update_value_labels()

func _on_back_pressed():
	GameManager.save_settings()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
