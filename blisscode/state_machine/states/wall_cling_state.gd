class_name WallClingState extends MoveState

var original_gravity_percent: float = 0
var current_gravity_percent: float = 0

func enter() -> void:
	super.enter()
	parent.set_flip_to_input_direction()
	parent.flip_h_lock = true
	parent.stop()
	original_gravity_percent = parent.character.get_physics_group().gravity_percent
	current_gravity_percent = parent.character.get_physics_group().wall_cling_gravity_percent
	parent.character.get_physics_group().gravity_percent = current_gravity_percent

func process_input(event: InputEvent) -> void:
	if parent.paralyzed:
		return
	if event.is_action_pressed("jump"):
		state_machine.dispatch("wall_jump")
		return
	super.process_input(event)

func process_physics(delta: float) -> void:
	if current_gravity_percent > 0:
		var direction = Vector2.DOWN
		parent.move(direction, delta)
	if not parent.is_wall_clinging():
		state_machine.dispatch("falling")
		return

func exit() -> void:
	super.exit()
	parent.flip_h_lock = false
	parent.character.get_physics_group().gravity_percent = original_gravity_percent