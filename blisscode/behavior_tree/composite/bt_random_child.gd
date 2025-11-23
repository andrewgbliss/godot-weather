class_name BTRandomChildNode extends BTNode

@export var weights: Array[float] = []

var current_child: BTNode = null # Track which child is currently running

func enter():
	current_child = null
	# Don't select a random child yet - we'll do that in process()

func process(delta: float) -> Status:
	# If no child is selected or the previous execution completed, pick a random child
	if current_child == null:
		var valid_children = []
		var valid_weights = []
		
		for i in range(get_child_count()):
			var child = get_child(i)
			if child is BTNode:
				valid_children.append(child)
				# Use the weight if available, otherwise default to 1.0
				if i < weights.size():
					valid_weights.append(weights[i])
				else:
					valid_weights.append(1.0)
		
		if valid_children.size() == 0:
			return Status.FAILURE # No valid children to run
		
		# Select a weighted random child
		var total_weight = 0.0
		for weight in valid_weights:
			total_weight += weight
		
		var random_value = randf() * total_weight
		var weight_sum = 0.0
		var selected_index = 0
		
		for i in range(valid_weights.size()):
			weight_sum += valid_weights[i]
			if random_value <= weight_sum:
				selected_index = i
				break
		
		current_child = valid_children[selected_index]
		current_child.enter()
	
	# Process the selected child
	var result = current_child.process(delta)
	
	if result != Status.RUNNING:
		# Child completed (success or failure), clean up
		current_child.exit()
		current_child = null
	
	return result # Return whatever the child returned

func exit():
	if current_child != null:
		current_child.exit()
		current_child = null
