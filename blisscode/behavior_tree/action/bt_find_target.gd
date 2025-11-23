class_name BTFindTarget extends BTNode

@export var group: StringName
@export var target_var: StringName = &"target"

var target

func process(_delta: float) -> Status:
	var nodes = agent.get_tree().get_nodes_in_group(group)
	if nodes.size() > 0:
		target = nodes[0]
	else:
		target = null
	blackboard.set_var(target_var, target)
	return Status.SUCCESS
