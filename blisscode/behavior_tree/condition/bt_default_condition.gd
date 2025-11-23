extends BTNode

@export var condition_key: String
@export var expected_value: String

func enter():
	print("Checking condition:", condition_key)

func process(delta: float) -> Status:
	if blackboard:
		var value = blackboard.get_value(condition_key)
		return Status.SUCCESS if value == expected_value else Status.FAILURE
	return Status.FAILURE

func exit():
	print("Exiting condition check:", condition_key)
