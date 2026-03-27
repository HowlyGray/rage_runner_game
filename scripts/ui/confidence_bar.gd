extends Control

@onready var confidence_bar = $VBoxContainer/ConfidenceBar
@onready var confidence_label = $VBoxContainer/ConfidenceLabel
@onready var status_label = $VBoxContainer/StatusLabel
@onready var immunity_timer_label = $VBoxContainer/ImmunityTimerLabel

var current_confidence: float = 50.0
var is_immune: bool = false
var immunity_time_left: float = 0.0

# Seuils de confiance
const LOW_CONFIDENCE = 25.0
const MEDIUM_CONFIDENCE = 50.0
const HIGH_CONFIDENCE = 75.0
const MAX_CONFIDENCE = 100.0

func _ready():
	update_display(50.0, false, 0.0)
	if immunity_timer_label:
		immunity_timer_label.visible = false

func _process(delta):
	if is_immune and immunity_time_left > 0:
		immunity_time_left -= delta
		update_immunity_timer()

func update_confidence(confidence: float, immune: bool, immunity_duration: float):
	current_confidence = confidence
	is_immune = immune
	immunity_time_left = immunity_duration
	update_display(confidence, immune, immunity_duration)

func update_display(confidence: float, immune: bool, immunity_duration: float):
	if not confidence_bar or not confidence_label or not status_label:
		return
	
	# Mettre à jour la barre
	confidence_bar.value = confidence
	
	if immune:
		# Mode immunité émotionnelle
		confidence_bar.modulate = Color(1.0, 0.85, 0.0)  # Doré brillant
		confidence_label.text = "Confiance: MAXIMUM!"
		confidence_label.modulate = Color(1.0, 0.85, 0.0)
		status_label.text = "⭐ IMMUNITÉ ÉMOTIONNELLE ⭐"
		status_label.modulate = Color(1.0, 0.85, 0.0)
		
		# Afficher le timer d'immunité
		if immunity_timer_label:
			immunity_timer_label.visible = true
			immunity_timer_label.text = "%.1fs restantes" % immunity_duration
			immunity_timer_label.modulate = Color(1.0, 0.85, 0.0)
	else:
		# Masquer le timer
		if immunity_timer_label:
			immunity_timer_label.visible = false
		
		# États normaux selon le niveau de confiance
		if confidence >= HIGH_CONFIDENCE:
			# Confiance élevée (75-99%)
			confidence_bar.modulate = Color(0.2, 1.0, 0.2)  # Vert
			confidence_label.text = "Confiance: %.0f%%" % confidence
			confidence_label.modulate = Color(0.2, 1.0, 0.2)
			status_label.text = "😎 CONFIANT"
			status_label.modulate = Color(0.2, 1.0, 0.2)
		elif confidence >= MEDIUM_CONFIDENCE:
			# Confiance moyenne (50-74%)
			confidence_bar.modulate = Color(0.2, 0.8, 1.0)  # Bleu clair
			confidence_label.text = "Confiance: %.0f%%" % confidence
			confidence_label.modulate = Color(0.2, 0.8, 1.0)
			status_label.text = "😊 SEREIN"
			status_label.modulate = Color(0.2, 0.8, 1.0)
		elif confidence >= LOW_CONFIDENCE:
			# Confiance basse (25-49%)
			confidence_bar.modulate = Color(1.0, 0.7, 0.0)  # Orange
			confidence_label.text = "Confiance: %.0f%%" % confidence
			confidence_label.modulate = Color(1.0, 0.7, 0.0)
			status_label.text = "😟 INQUIET"
			status_label.modulate = Color(1.0, 0.7, 0.0)
		else:
			# Confiance très basse (0-24%)
			confidence_bar.modulate = Color(1.0, 0.2, 0.2)  # Rouge
			confidence_label.text = "Confiance: %.0f%%" % confidence
			confidence_label.modulate = Color(1.0, 0.2, 0.2)
			status_label.text = "😰 PANIQUÉ"
			status_label.modulate = Color(1.0, 0.2, 0.2)

func update_immunity_timer():
	if immunity_timer_label and is_immune:
		immunity_timer_label.text = "%.1fs restantes" % max(0, immunity_time_left)
