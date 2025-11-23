class_name LadderClimbState extends MoveState

@export var physics_group: PhysicsGroup

func enter() -> void:
	super.enter()
	parent.stop()
	parent.character.set_physics_group_override(physics_group)

func exit() -> void:
	super.exit()
	parent.character.reset_physics_group_override()

func process_physics(delta: float) -> void:
	var direction = parent.controls.get_movement_direction()
	parent.move(direction, delta)
	if direction == Vector2.ZERO:
		state_machine.dispatch("ladder_idle")
		return
	if not parent.is_on_ladder():
		state_machine.dispatch("idle")
		return
