extends Camera2D

var shake_intensity: float = 0.0
var shake_decay: float = 5.0

func _process(delta):
	if shake_intensity > 0:
		shake_intensity = lerp(shake_intensity, 0.0, shake_decay * delta)
		offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
	else:
		offset = Vector2.ZERO

func add_shake(intensity: float):
	shake_intensity += intensity
