class_name BTPlayer extends Node

@export var root_node: Node
@export var blackboard: BTBlackboard
@export var agent: Node
@export var is_running: bool = false
@export var one_shot: bool = false
var has_entered: bool = false

func _ready():
	if blackboard == null:
		blackboard = BTBlackboard.new()
		add_child(blackboard)
		
	if root_node:
		_assign_to_tree(root_node) # Recursively assign blackboard & agent

func _process(delta: float) -> void:
	if not is_running:
		return
	if root_node:
		if not has_entered:
			root_node.enter()
			has_entered = true
			
		var result = root_node.process(delta)
		if result != BTNode.Status.RUNNING:
			root_node.exit()
			if one_shot:
				stop()
			else:
				root_node.enter()
			
func _assign_to_tree(node: Node):
	if node is BTNode:
		node.blackboard = blackboard
		node.agent = agent # Assign the agent to each behavior node

	for child in node.get_children():
		_assign_to_tree(child) # Recurse into the behavior tree

func start() -> void:
	is_running = true
	has_entered = false

func stop() -> void:
	is_running = false
	has_entered = false

func save():
	return blackboard.save()

func restore(new_data):
	blackboard.restore(new_data)
