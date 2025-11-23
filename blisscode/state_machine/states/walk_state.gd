class_name WalkState extends MoveState

func enter() -> void:
	super.enter()
	play_animation()

func process_physics(delta: float) -> void:
	if parent.is_falling():
		state_machine.dispatch("falling")
		return
	var direction = parent.controls.get_movement_direction()
	parent.move(direction, delta)
	if parent.is_on_ladder() and parent.controls.is_pressing_up():
		state_machine.dispatch("ladder_climb")
		return
	if direction == Vector2.ZERO:
		if parent.controls.is_pressing_down():
			state_machine.dispatch("crouch_idle")
			return
		state_machine.dispatch("idle")
	else:
		if parent.controls.is_pressing_slide():
			state_machine.dispatch("slide")
			return
		if parent.controls.is_pressing_down():
			state_machine.dispatch("crouch_walk")
			return
		if parent.controls.is_pushing():
			state_machine.dispatch("push")
			return
		if parent.controls.is_running():
			state_machine.dispatch("run")
