class_name BTMoveToRandomPolygonPos extends BTNode

@export var move_to_var: StringName = &"move_to"

func process(_delta: float) -> Status:
	var map = agent.navigation_agent.get_navigation_map()
	if map == null:
		return Status.FAILURE
	var random_point = NavigationServer2D.map_get_random_point(map, 1, false)
	blackboard.set_var(move_to_var, random_point)
	return Status.SUCCESS
