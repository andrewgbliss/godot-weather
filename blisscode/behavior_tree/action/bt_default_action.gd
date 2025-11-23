extends BTNode

@export var action_name: String = "default_action"

func enter():
	print("Starting action:", action_name)

func process(delta: float) -> Status:
	print("Performing action:", action_name)
	
	if blackboard:
		blackboard.set_value("last_action", action_name)
	
	return Status.SUCCESS

func exit():
	print("Finished action:", action_name)
