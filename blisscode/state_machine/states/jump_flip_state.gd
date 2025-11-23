class_name JumpFlipState extends MoveState

func enter() -> void:
	super.enter()
	parent.jump()

func process_physics(delta: float) -> void:
	var direction = parent.controls.get_movement_direction()
	parent.move(direction, delta)
	if parent.is_on_ladder() and parent.controls.is_pressing_up():
		state_machine.dispatch("ladder_climb")
		return
	if parent.is_on_floor():
		state_machine.dispatch("land")
		return
	if parent.is_falling():
		state_machine.dispatch("falling")
		return
