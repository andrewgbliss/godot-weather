class_name BTChooseRandomPos extends BTNode

@export var min_dir_range: float = -1000
@export var max_dir_range: float = 1000

@export var position_var: StringName = &"pos"
@export var dir_var: StringName = &"dir"

func process(_delta: float) -> Status:
	var pos: Vector2
	var dir = rand_dir()
	pos = rand_pos(dir)
	blackboard.set_var(position_var, pos)
	return Status.SUCCESS

func rand_pos(dir):
	var vector: Vector2
	var distance = randi_range(min_dir_range, max_dir_range) * dir
	var final_pos = (distance + agent.global_position.x)
	vector.x = final_pos
	return vector

func rand_dir():
	var dir = randi_range(-2, 1)
	if abs(dir) != dir:
		dir = -1
	else:
		dir = 1
	blackboard.set_var(dir_var, dir)
	return dir
