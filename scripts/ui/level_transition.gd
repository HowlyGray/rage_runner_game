extends Control

@onready var level_label = $CenterContainer/VBoxContainer/LevelLabel
@onready var message_label = $CenterContainer/VBoxContainer/MessageLabel
@onready var continue_button = $CenterContainer/VBoxContainer/ContinueButton

var transition_timer: float = 0.0
const AUTO_CONTINUE_TIME = 3.0

func _ready():
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
	
	update_display()

func _process(delta):
	transition_timer += delta
	if transition_timer >= AUTO_CONTINUE_TIME:
		_on_continue_pressed()

func update_display():
	if level_label:
		level_label.text = "NIVEAU %d" % GameManager.current_level
	
	if message_label:
		var config = GameManager.get_level_config()
		message_label.text = "Préparez-vous!\nDurée: %d secondes\nDifficulté accrue!" % config.duration

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://scenes/game/game_scene.tscn")
