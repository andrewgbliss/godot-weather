class_name BTWaitForSeconds extends BTNode

@export var wait_time: float = 1.0  # Time to wait before succeeding

var elapsed_time: float = 0.0

func enter():
	elapsed_time = 0.0  # Reset the timer
	#print(agent.name, "started waiting for", wait_time, "seconds")

func process(delta: float) -> Status:
	elapsed_time += delta
	if elapsed_time >= wait_time:
		return Status.SUCCESS
	return Status.RUNNING  # Keep running until time is up

func exit():
	#print(agent.name, "finished waiting")
	pass
