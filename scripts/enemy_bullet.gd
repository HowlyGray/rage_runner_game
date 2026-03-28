extends Area3D

var speed: float = 15.0
var damage: int = 1
var direction: Vector3 = Vector3.BACK
var spawn_position: Vector3 = Vector3.ZERO

@onready var mesh = $MeshInstance3D
var is_dodged: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	spawn_position = global_position
	add_to_group("enemy_bullets")

func _process(delta):
	position += direction * speed * delta
	if global_position.distance_to(spawn_position) > 100.0:
		queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()

func set_as_dodged():
	if not is_dodged:
		is_dodged = true
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			players[0].on_comment_dodged()
