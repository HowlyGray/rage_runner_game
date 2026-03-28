extends Camera3D

var shake_intensity: float = 0.0
var shake_decay: float = 5.0
var base_offset: Vector3 = Vector3.ZERO

func _ready():
	base_offset = transform.origin

func _process(delta):
	if shake_intensity > 0:
		shake_intensity = lerp(shake_intensity, 0.0, shake_decay * delta)
		var shake_offset = Vector3(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		transform.origin = base_offset + shake_offset
	else:
		transform.origin = base_offset

func add_shake(intensity: float):
	shake_intensity += intensity * 0.1 # Réduire l'intensité pour la 3D
