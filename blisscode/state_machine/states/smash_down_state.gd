class_name SmashDownState extends AnimationState

@export var physics_group: PhysicsGroup
@export var animation_started: String = ""
@export var animation_performed: String = ""
@export var animation_collided: String = ""
@export var wait_finish_time: float = 1.5
@export var collide_effect: PackedScene

enum State {
	STARTED,
	PERFORMED,
	COLLIDED
}

var state = State.STARTED

func enter() -> void:
	super.enter()
	parent.flip_h_lock = true
	parent.stop()
	state = State.STARTED
	parent.character.set_physics_group_override(physics_group)
	play_animation_name(animation_started)

func exit() -> void:
	super.exit()
	parent.flip_h_lock = false
	parent.character.reset_physics_group_override()

func process_physics(delta: float) -> void:
	if parent.move(Vector2.DOWN, delta):
		for i in parent.get_slide_collision_count():
			var col = parent.get_slide_collision(i)
			if collide_effect:
				var effect = collide_effect.instantiate()
				effect.global_position = col.get_position()
				get_tree().current_scene.add_child(effect)
	if is_animation_finished:
		if state == State.STARTED:
			play_animation_name(animation_performed)
			state = State.PERFORMED
		elif state == State.PERFORMED:
			play_animation_name(animation_collided)
			state = State.COLLIDED
	if parent.is_on_floor() and is_animation_finished:
		if state != State.COLLIDED:
			play_animation_name(animation_collided)
			state = State.COLLIDED
		elif state == State.COLLIDED:
			await get_tree().create_timer(wait_finish_time).timeout
			state_machine.dispatch("idle", true)
