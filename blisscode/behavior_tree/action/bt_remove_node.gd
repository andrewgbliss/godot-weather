class_name BTRemoveNode extends BTNode

@export var node_path: NodePath

func process(_delta: float) -> Status:
	if node_path.is_empty():
		return Status.FAILURE
	
	var node = get_node_or_null(node_path)
	if node == null:
		return Status.FAILURE
	
	node.queue_free()
	return Status.SUCCESS
