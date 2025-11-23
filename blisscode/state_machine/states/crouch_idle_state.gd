class_name CrouchIdleState extends MoveState

@export var collision_shape: CollisionShape2D
@export var crouch_collision_shape: CollisionShape2D

func enter() -> void:
	super.enter()
	if collision_shape:
		collision_shape.disabled = true
	if crouch_collision_shape:
		crouch_collision_shape.disabled = false

func exit() -> void:
	super.exit()
	if collision_shape:
		collision_shape.disabled = false
	if crouch_collision_shape:
		crouch_collision_shape.disabled = true

func process_physics(delta: float) -> void:
	if parent.is_falling():
		state_machine.dispatch("falling")
		return
	var direction = parent.controls.get_movement_direction()
	parent.move(direction, delta)
	if direction != Vector2.ZERO:
		if parent.controls.is_pressing_down():
			state_machine.dispatch("crouch_walk")
			return
		if parent.controls.is_running():
			state_machine.dispatch("run")
		else:
			state_machine.dispatch("walk")
	else:
		if not parent.controls.is_pressing_down():
			state_machine.dispatch("idle")
			return
