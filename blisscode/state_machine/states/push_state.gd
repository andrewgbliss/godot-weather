class_name PushState extends MoveState

func process_physics(delta: float) -> void:
	if parent.is_falling():
		state_machine.dispatch("falling")
		return
	var direction = parent.controls.get_movement_direction()
	parent.move(direction, delta)
	if direction == Vector2.ZERO:
		state_machine.dispatch("push_idle")