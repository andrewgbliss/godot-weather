class_name IdleState extends MoveState

func process_physics(delta: float) -> void:
	if parent.is_falling():
		state_machine.dispatch("falling")
		return
	var direction = parent.controls.get_movement_direction()
	parent.move(direction, delta)
	if direction != Vector2.ZERO:
		if parent.controls.is_pressing_down():
			state_machine.dispatch("crouch_idle")
		elif parent.controls.is_running():
			state_machine.dispatch("run")
		else:
			state_machine.dispatch("walk")
	elif parent.controls.is_pressing_down():
		state_machine.dispatch("crouch_idle")
		return
	if parent.is_dangling():
		state_machine.dispatch("dangling")
		return
	if parent.is_on_ladder() and parent.controls.is_pressing_up():
		state_machine.dispatch("ladder_climb")
		return