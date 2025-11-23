class_name BTWaitUntilReachedPosition extends BTNode

@export var move_to_var := &"move_to"
@export var target_var := &"target"

@export var tolerance = 10

func process(_delta: float) -> Status:
	var target = blackboard.get_var(target_var, null)
	if target != null:
		blackboard.remove_var(move_to_var)
		return Status.FAILURE

	var move_to: Vector2 = blackboard.get_var(move_to_var, Vector2.ZERO)
	if agent.global_position.distance_to(move_to) < tolerance:
		return Status.SUCCESS
	return Status.RUNNING
