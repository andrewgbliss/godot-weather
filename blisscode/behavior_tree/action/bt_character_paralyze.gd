class_name BTCharacterParalyze extends BTNode

@export var is_paralyzed: bool = true
@export var stop_velocity: bool = true

func process(_delta: float) -> Status:
	agent.is_paralyzed = is_paralyzed
	if stop_velocity:
		agent.velocity = Vector2.ZERO
	return Status.SUCCESS
