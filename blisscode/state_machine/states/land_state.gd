class_name LandState extends MoveState

func process_physics(delta: float) -> void:
	var direction = parent.controls.get_movement_direction()
	if direction == Vector2.ZERO:
		if parent.is_on_floor() and is_animation_finished:
			dispatch()
			return
	else:
		parent.move(direction, delta)
		if parent.controls.is_walking():
			state_machine.dispatch("walk")
		elif parent.controls.is_running():
			state_machine.dispatch("run")
		else:
			state_machine.dispatch("idle")
