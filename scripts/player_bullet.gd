extends Area3D

var speed: float = 30.0
var damage: int = 1
var direction: Vector3 = Vector3.FORWARD
var piercing: bool = false
var spawn_position: Vector3 = Vector3.ZERO

@onready var mesh = $MeshInstance3D

func _ready():
	body_entered.connect(_on_body_entered)
	spawn_position = global_position

func _process(delta):
	position += direction * speed * delta
	if global_position.distance_to(spawn_position) > 100.0:
		queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
		if not piercing:
			queue_free()
