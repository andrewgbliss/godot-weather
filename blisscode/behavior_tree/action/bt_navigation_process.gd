class_name BTNavigationProcess extends BTNode

@export var speed : float = 100.0
@export var require_target: bool = false
@export var acquire_target: bool = false
@export var target_var := &"target"
@export var direction_var: StringName = &"movement_direction"
@export var is_walking_var := &"is_walking"
@export var is_running_var := &"is_running"

func enter():
	super()
	blackboard.set_var(is_walking_var, true)

func process(_delta: float) -> Status:
	if require_target:
		var target: CharacterBody2D = blackboard.get_var(target_var, null)
		if target == null:
			blackboard.remove_var(direction_var)
			blackboard.set_var(is_walking_var, false)
			return Status.FAILURE
	
	if acquire_target:
		var target: CharacterBody2D = blackboard.get_var(target_var, null)
		if target != null:
			blackboard.remove_var(direction_var)
			blackboard.set_var(is_walking_var, false)
			return Status.FAILURE
	
	if agent.navigation_agent == null:
		blackboard.remove_var(direction_var)
		blackboard.set_var(is_walking_var, false)
		return Status.FAILURE

	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(agent.navigation_agent.get_navigation_map()) == 0:
		return Status.RUNNING
		
	if agent.navigation_agent.is_navigation_finished():
		agent._on_velocity_computed(Vector2.ZERO)
		blackboard.remove_var(direction_var)
		blackboard.set_var(is_walking_var, false)
		return Status.SUCCESS

	var next_path_position: Vector2 = agent.navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = agent.global_position.direction_to(next_path_position) * speed
	if agent.navigation_agent.avoidance_enabled:
		agent.navigation_agent.set_velocity(new_velocity)
	else:
		agent._on_velocity_computed(new_velocity)
		
	return Status.RUNNING
	
