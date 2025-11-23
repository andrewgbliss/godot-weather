class_name BTWaitForRandomSeconds extends BTNode

@export var min_wait_time: float = 1.0 # Minimum time to wait before succeeding
@export var max_wait_time: float = 5.0 # Maximum time to wait before succeeding

var elapsed_time: float = 0.0
var wait_time: float = 0.0

func enter():
	elapsed_time = 0.0
	wait_time = randf_range(min_wait_time, max_wait_time)
	#print(agent.name, "started waiting for", wait_time, "seconds")

func process(delta: float) -> Status:
	elapsed_time += delta
	if elapsed_time >= wait_time:
		return Status.SUCCESS
	return Status.RUNNING # Keep running until time is up

func exit():
	#print(agent.name, "finished waiting")
	pass
