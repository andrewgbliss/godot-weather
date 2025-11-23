class_name BTSetDirectionFromMoveTo extends BTNode

@export var move_to_var := &"move_to"
@export var direction_var: StringName = &"movement_direction"

func process(_delta: float) -> Status:
	var move_to: Vector2 = blackboard.get_var(move_to_var, Vector2.ZERO)
	var direction = (move_to - agent.global_position).normalized()
	blackboard.set_var(direction_var, direction)
	return Status.SUCCESS
