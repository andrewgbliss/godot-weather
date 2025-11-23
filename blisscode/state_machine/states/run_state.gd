class_name RunState extends MoveState

func process_input(event: InputEvent) -> void:
	if parent.paralyzed:
		return
	if event.is_action_pressed("jump"):
		state_machine.dispatch("jump_flip")
		return
	super.process_input(event)

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
		state_machine.dispatch("idle")
	else:
		if parent.controls.is_pressing_slide():
			state_machine.dispatch("slide")
			return
		if parent.controls.is_pushing():
			state_machine.dispatch("push")
			return
		if parent.controls.is_walking():
			state_machine.dispatch("walk")
