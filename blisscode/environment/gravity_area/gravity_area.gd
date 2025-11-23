class_name GravityArea extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterController:
		var gravity_dir = global_position.direction_to(body.global_position)
		body.gravity_dir = gravity_dir.normalized()

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterController:
		body.gravity_dir = body.default_gravity_dir
