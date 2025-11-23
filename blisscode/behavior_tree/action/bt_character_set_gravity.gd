class_name BTCharacterSetGravity extends BTNode

@export var use_gravity: bool = true

func process(_delta: float) -> Status:
	agent.use_gravity = use_gravity
	return Status.SUCCESS
