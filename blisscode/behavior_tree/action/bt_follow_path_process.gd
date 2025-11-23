class_name BTFollowPathProcess extends BTNode
 
@export var speed: float = 0.1
@export var success_on_end: bool = false
@export var require_target: bool = false
@export var acquire_target: bool = false
@export var target_var := &"target"
@export var direction_var: StringName = &"movement_direction"
@export var is_walking_var := &"is_walking"
@export var is_running_var := &"is_running"

var path: Path2D
var path_follow: PathFollow2D
var follow_path_velocity
var previous_global_position: Vector2 = Vector2.ZERO

func _select_path():
	if path == null:
		if agent.paths and agent.paths.size() > 0:
			# Select a random path from the available paths
			var random_index = randi() % agent.paths.size()
			path = agent.paths[random_index]
			path_follow = path.get_child(0)
		else:
			push_error("No paths available for FollowPathProcess")

func enter():
	super ()
	blackboard.set_var(is_walking_var, true)
	_select_path()

func process(delta: float) -> Status:
	if require_target:
		var target: CharacterBody2D = blackboard.get_var(target_var, null)
		if target == null:
			blackboard.set_var(is_walking_var, false)
			blackboard.remove_var(direction_var)
			return Status.FAILURE

	if acquire_target:
		var target: CharacterBody2D = blackboard.get_var(target_var, null)
		if target != null:
			blackboard.set_var(is_walking_var, false)
			blackboard.remove_var(direction_var)
			return Status.FAILURE

	if path_follow == null:
		blackboard.set_var(is_walking_var, false)
		blackboard.remove_var(direction_var)
		return Status.FAILURE

	path_follow.progress_ratio += speed * delta
	var direction = (path_follow.global_position - agent.global_position).normalized()
	blackboard.set_var(direction_var, direction)

	var new_velocity: Vector2 = agent.global_position.direction_to(path_follow.global_position) * agent.character.speed
	agent._on_velocity_computed(new_velocity)

	if success_on_end and path_follow.progress_ratio >= 1.0:
		blackboard.set_var(is_walking_var, false)
		blackboard.remove_var(direction_var)
		return Status.SUCCESS

	return Status.RUNNING
