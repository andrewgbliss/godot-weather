class_name SlideState extends MoveState

@export var collision_shape: CollisionShape2D
@export var crouch_collision_shape: CollisionShape2D

var slide_time: float = 0
var slide_stop_on_end: bool = false
var slide_time_elapsed: float = 0

var direction = Vector2.ZERO

func exit() -> void:
	super.exit()
	if collision_shape:
		collision_shape.disabled = false
	if crouch_collision_shape:
		crouch_collision_shape.disabled = true

func enter():
	super.enter()
	if collision_shape:
		collision_shape.disabled = true
	if crouch_collision_shape:
		crouch_collision_shape.disabled = false
	slide_time_elapsed = 0
	var physics = parent.character.get_physics_group()
	slide_time = physics.slide_time
	slide_stop_on_end = physics.slide_stop_on_end
	direction = parent.slide()
	play_animation()

func process_physics(delta: float):
	parent.move(direction, delta)
	slide_time_elapsed += delta
	if slide_time_elapsed >= slide_time:
		if slide_stop_on_end:
			parent.stop()
		state_machine.dispatch("slide_stop")
