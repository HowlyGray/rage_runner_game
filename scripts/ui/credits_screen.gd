extends Control

@onready var back_button = $BackButton
@onready var credits_label = $ScrollContainer/CreditsLabel

func _ready():
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	setup_credits_text()

func setup_credits_text():
	if credits_label:
		credits_label.text = """
		RAGE RUNNER
		
		Un jeu créé avec Godot Engine 4.5
		
		═══════════════════════════
		
		DÉVELOPPEMENT
		Stéphane (Mosaic Mind)
		
		═══════════════════════════
		
		GAME DESIGN
		Concept Original: Éviter les commentaires toxiques
		
		═══════════════════════════
		
		PROGRAMMATION
		• Système de débuffs
		• Système de scoring
		• Gestion des niveaux
		• Interface utilisateur
		
		═══════════════════════════
		
		REMERCIEMENTS
		• La communauté Godot
		• Tous les joueurs
		• Les testeurs
		
		═══════════════════════════
		
		MOTEUR DE JEU
		Godot Engine 4.5
		www.godotengine.org
		
		═══════════════════════════
		
		VERSION
		1.0.0
		
		═══════════════════════════
		
		Merci d'avoir joué!
		
		Restez positifs! 💪
		"""

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
