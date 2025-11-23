class_name BTTimeout extends BTNode

@export var timeout_seconds: float = 1.0

var elapsed_time: float = 0.0

func enter() -> void:
	elapsed_time = 0.0

func process(delta: float) -> Status:
	elapsed_time += delta
	
	if elapsed_time >= timeout_seconds:
		elapsed_time = 0.0
		return Status.SUCCESS
		
	var child_status = get_child(0).process(delta)
	return child_status if child_status != Status.SUCCESS else Status.RUNNING
