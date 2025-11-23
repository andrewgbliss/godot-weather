class_name DanglingState extends MoveState

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