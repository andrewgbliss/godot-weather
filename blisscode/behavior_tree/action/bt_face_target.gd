class_name BTFaceTarget extends BTNode

@export var target_var: StringName = &"target"

var target

func process(_delta: float) -> Status:
	target = blackboard.get_var(target_var)
	if not target:
		return Status.FAILURE

	var direction = (target.global_position - agent.global_position).normalized()
	agent.face_direction(direction)

	return Status.SUCCESS
