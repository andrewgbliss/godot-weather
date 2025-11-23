class_name BTHasTarget extends BTNode

@export var target_var := &"target"

func process(_delta: float) -> Status:
	var target: CharacterBody2D = blackboard.get_var(target_var, null)
	if target == null:
		return Status.FAILURE
	return Status.SUCCESS
