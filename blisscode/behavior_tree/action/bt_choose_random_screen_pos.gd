class_name BTChooseRandomScreenPos extends BTNode

@export var move_to_var: StringName = &"move_to"

func process(_delta: float) -> Status:
	var viewport_size = agent.get_viewport().get_visible_rect().size
	var pos = Vector2(
		randf_range(0, viewport_size.x),
		randf_range(0, viewport_size.y)
	)
	blackboard.set_var(move_to_var, pos)
	return Status.SUCCESS
