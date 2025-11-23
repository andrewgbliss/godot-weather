class_name BTSetVar extends BTNode

@export var var_name: StringName
@export var value: Variant = false

func process(_delta: float) -> Status:
	blackboard.set_var(var_name, value)
	return Status.SUCCESS
