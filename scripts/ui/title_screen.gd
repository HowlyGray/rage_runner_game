extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var animation_player = $AnimationPlayer

var press_any_key: bool = true

func _ready():
	# Animer le titre
	if animation_player and animation_player.has_animation("title_pulse"):
		animation_player.play("title_pulse")

func _input(event):
	if press_any_key and (event is InputEventKey or event is InputEventMouseButton):
		if event.pressed:
			go_to_main_menu()

func go_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_start_button_pressed():
	go_to_main_menu()
