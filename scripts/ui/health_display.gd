extends HBoxContainer

var heart_full = "❤️"
var heart_empty = "🤍"

func update_health(current: int, maximum: int):
	# Effacer tous les cœurs actuels
	for child in get_children():
		child.queue_free()
	
	# Créer les nouveaux cœurs
	for i in range(maximum):
		var heart_label = Label.new()
		heart_label.add_theme_font_size_override("font_size", 32)
		
		if i < current:
			heart_label.text = heart_full
		else:
			heart_label.text = heart_empty
		
		add_child(heart_label)
