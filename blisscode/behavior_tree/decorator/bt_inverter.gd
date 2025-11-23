class_name BTInverter extends BTNode

var child_node: BTNode = null

func _ready():
	# Find the first child that is a BTNode
	for child in get_children():
		if child is BTNode:
			child_node = child
			break

func enter():
	if child_node:
		child_node.enter()

func process(delta: float) -> Status:
	if not child_node:
		return Status.FAILURE
	
	var result = child_node.process(delta)
	
	match result:
		Status.SUCCESS:
			return Status.FAILURE
		Status.FAILURE:
			return Status.SUCCESS
		Status.RUNNING:
			return Status.RUNNING
	
	# Default fallback (should never reach here)
	return Status.FAILURE

func exit():
	if child_node:
		child_node.exit()
