class_name WallJumpState extends MoveState

var aim_direction: Vector2 = Vector2.ZERO

func enter() -> void:
	super.enter()
	aim_direction = parent.controls.get_aim_direction()
	parent.wall_jump()

func process_physics(delta: float) -> void:
	parent.move(aim_direction, delta)
	if parent.is_on_floor():
		state_machine.dispatch("land")
		return
	if parent.is_falling():
		state_machine.dispatch("falling")
		return
