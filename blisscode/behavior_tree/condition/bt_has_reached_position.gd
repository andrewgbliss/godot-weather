class_name BTHasReachedPosition extends BTNode

@export var move_to_var := &"move_to"

@export var tolerance = 10

func process(_delta: float) -> Status:
	var move_to: Vector2 = blackboard.get_var(move_to_var, Vector2.ZERO)
	if agent.global_position.distance_to(move_to) < tolerance:
		return Status.SUCCESS
	return Status.FAILURE
