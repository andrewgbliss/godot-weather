class_name BTSetPosByNode2D extends BTNode

@export var node2d: Node2D
@export var position_var: StringName = &"pos"

func process(_delta: float) -> Status:
	blackboard.set_var(position_var, node2d.position)
	return Status.SUCCESS
