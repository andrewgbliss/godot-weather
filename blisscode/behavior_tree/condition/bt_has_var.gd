class_name BTHasVar extends BTNode

@export var var_name: StringName

func process(_delta: float) -> Status:
	return Status.SUCCESS if blackboard.has_var(var_name) else Status.FAILURE
