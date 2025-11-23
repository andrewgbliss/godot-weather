class_name BTSelectorNode extends BTNode

var current_child_index: int = 0
var running_child: BTNode = null # Track which child is currently running

func enter():
	current_child_index = 0 # Reset selector when it starts
	running_child = null

func process(delta: float) -> Status:
	while current_child_index < get_child_count():
		var child = get_child(current_child_index)

		if child is BTNode: # Ensure it's a behavior node
			if running_child != child: # Call enter() only if it's a new child
				child.enter()
				running_child = child

			var result = child.process(delta)

			if result == Status.SUCCESS:
				child.exit()
				running_child = null
				return Status.SUCCESS # Selector succeeds if any child succeeds
			elif result == Status.RUNNING:
				return Status.RUNNING # Keep running the current child
			else: # FAILURE
				child.exit()
				running_child = null
				current_child_index += 1 # Try the next child
		else:
			# Skip non-BTNode children
			current_child_index += 1

	# Reset for next time this selector is run
	current_child_index = 0
	return Status.FAILURE # If all children fail, return FAILURE

func exit():
	if running_child != null:
		running_child.exit()
	running_child = null
