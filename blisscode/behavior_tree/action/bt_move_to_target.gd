class_name BTMoveToTarget extends BTNode

@export var move_to_var := &"move_to"
@export var target_var := &"target"

func process(_delta: float) -> Status:
	var target = blackboard.get_var(target_var)
	if not target:
		blackboard.remove_var(move_to_var)
		return Status.FAILURE
	
	if target:
		blackboard.set_var(move_to_var, target.global_position)
	
	return Status.SUCCESS
