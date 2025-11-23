class_name JumpState extends MoveState

func enter() -> void:
	super.enter()
	parent.jump()

func process_physics(delta: float) -> void:
	var direction = parent.controls.get_movement_direction()
	parent.move(direction, delta)
	if parent.is_on_ladder() and parent.controls.is_pressing_up():
		state_machine.dispatch("ladder_climb")
		return
	if parent.controls.is_attacking_up():
		state_machine.dispatch("up_thrust")
		return
	if parent.controls.is_attacking_down():
		state_machine.dispatch("down_thrust")
		return
	if parent.is_on_floor():
		state_machine.dispatch("land")
		return
	if parent.is_ledge_grabbing():
		state_machine.dispatch("ledge_grab")
		return
	if parent.is_wall_clinging():
		state_machine.dispatch("wall_cling")
		return
	if parent.is_falling():
		state_machine.dispatch("falling")
		return
