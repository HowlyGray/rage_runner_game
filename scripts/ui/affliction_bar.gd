extends Control

@onready var affliction_bar = $VBoxContainer/AfflictionBar
@onready var affliction_label = $VBoxContainer/AfflictionLabel
@onready var status_label = $VBoxContainer/StatusLabel

# Temps maximal affiché (pour la normalisation)
const MAX_DISPLAY_TIME = 20.0

var current_affliction: float = 0.0

func _ready():
	update_display(0.0)

func update_affliction(affliction_time: float):
	current_affliction = affliction_time
	update_display(affliction_time)

func update_display(time: float):
	if not affliction_bar or not affliction_label or not status_label:
		return
	
	# Calculer la valeur normalisée pour la barre
	var normalized_value = abs(time) / MAX_DISPLAY_TIME
	normalized_value = clamp(normalized_value, 0.0, 1.0)
	
	if time > 0:
		# En débuff (rouge)
		affliction_bar.value = normalized_value * 100
		affliction_bar.modulate = Color(1.0, 0.3, 0.3)  # Rouge
		affliction_label.text = "Affliction: %.1fs" % time
		affliction_label.modulate = Color(1.0, 0.3, 0.3)
		status_label.text = "😣 AFFLIGÉ"
		status_label.modulate = Color(1.0, 0.3, 0.3)
	elif time < 0:
		# En buff (vert)
		affliction_bar.value = normalized_value * 100
		affliction_bar.modulate = Color(0.3, 1.0, 0.3)  # Vert
		affliction_label.text = "Buff: %.1fs" % abs(time)
		affliction_label.modulate = Color(0.3, 1.0, 0.3)
		status_label.text = "💪 MOTIVÉ"
		status_label.modulate = Color(0.3, 1.0, 0.3)
	else:
		# Neutre
		affliction_bar.value = 0
		affliction_bar.modulate = Color(0.5, 0.5, 0.5)  # Gris
		affliction_label.text = "Affliction: 0s"
		affliction_label.modulate = Color(1.0, 1.0, 1.0)
		status_label.text = "😊 NORMAL"
		status_label.modulate = Color(1.0, 1.0, 1.0)
