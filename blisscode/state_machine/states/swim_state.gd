class_name SwimState extends MoveState

@export var physics_group: PhysicsGroup

func enter() -> void:
	super.enter()
	parent.character.set_physics_group_override(physics_group)

func exit() -> void:
	super.exit()
	parent.character.reset_physics_group_override()

func process_input(event: InputEvent) -> void:
	if parent.paralyzed:
		return
	if event.is_action_pressed("dash"):
		parent.dash()
	if event.is_action_pressed("change_gravity_dir"):
		GameManager.toggle_anti_gravity()

func process_physics(delta: float) -> void:
	var direction = parent.controls.get_movement_direction()
	parent.move(direction, delta)
