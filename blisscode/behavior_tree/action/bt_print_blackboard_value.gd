class_name BTBlackboardPrintValue extends BTNode

@export var var_name: String

func process(_delta: float) -> Status:
	var value = blackboard.get_var(var_name, null)
	print(value)
	return Status.SUCCESS
