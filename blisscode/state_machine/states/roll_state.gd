class_name RollState extends MoveState

@export var collision_shape: CollisionShape2D
@export var crouch_collision_shape: CollisionShape2D

var direction = Vector2.ZERO

func enter() -> void:
	super.enter()
	if collision_shape:
		collision_shape.disabled = true
	if crouch_collision_shape:
		crouch_collision_shape.disabled = false
	direction = parent.roll()

func process_input(event: InputEvent) -> void:
	if parent.paralyzed:
		return
	elif event.is_action_pressed("attack_left_hand") or event.is_action_pressed("attack_right_hand"):
		super.attack()

func process_physics(delta: float):
	parent.move(direction, delta)
	if is_animation_finished:
		state_machine.dispatch("idle")

func exit() -> void:
	super.exit()
	if collision_shape:
		collision_shape.disabled = false
	if crouch_collision_shape:
		crouch_collision_shape.disabled = true
