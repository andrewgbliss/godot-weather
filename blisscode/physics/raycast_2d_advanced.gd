class_name RayCast2DAdvanced extends RayCast2D

@export var agent: CharacterController
@export var facing_left_position: Vector2 = Vector2.ZERO
@export var facing_right_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	if agent:
		agent.facing_direction_changed.connect(_on_facing_direction_changed)

func _on_facing_direction_changed():
	if agent and agent.animated_sprite:
		if agent.animated_sprite.flip_h:
			position = facing_left_position
			target_position.x = - target_position.x
		else:
			position = facing_right_position
			target_position.x = abs(target_position.x)
