class_name BTNavigationAgentSetMoveTo extends BTNode

@export var move_to_var: StringName = &"move_to"

func process(_delta: float) -> Status:
	if agent.navigation_agent == null:
		return Status.FAILURE
		
	var move_to = blackboard.get_var(move_to_var)
	if move_to == null:
		return Status.FAILURE
	
	agent.navigation_agent.set_target_position(move_to)
	return Status.SUCCESS
