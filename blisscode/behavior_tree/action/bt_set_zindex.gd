class_name BTSetZIndex extends BTNode

@export var z_index: int = 0

func process(_delta: float) -> Status:
	agent.z_index = z_index
	return Status.SUCCESS
