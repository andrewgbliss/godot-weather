class_name PushIdleState extends MoveState

func process_physics(delta: float) -> void:
	var direction = parent.controls.get_movement_direction()
	parent.move(direction, delta)
	if direction != Vector2.ZERO:
		if parent.controls.is_pushing():
			state_machine.dispatch("push")
		elif parent.controls.is_walking():
			state_machine.dispatch("walk")
		elif parent.controls.is_running():
			state_machine.dispatch("run")
