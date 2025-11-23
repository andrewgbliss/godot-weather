class_name BTPrintValue extends BTNode

@export var value: String

func process(_delta: float) -> Status:
	print(value)
	return Status.SUCCESS
