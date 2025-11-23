class_name BTRemoveVar extends BTNode

@export var var_name: StringName

func process(_delta: float) -> Status:
	blackboard.remove_var(var_name)
	return Status.SUCCESS
