class_name DashState extends AnimationState

var dash_time_elapsed: float = 0
var dash_time: float = 0
var stop_on_end: bool = false

var direction = Vector2.ZERO

func enter():
	super ()
	dash_time_elapsed = 0
	var physics = parent.character.get_physics_group()
	dash_time = physics.dash_time
	stop_on_end = physics.stop_on_end
	direction = parent.dash()
	play_animation()

func process_physics(delta: float):
	parent.move(direction, delta)
	dash_time_elapsed += delta
	if dash_time_elapsed >= dash_time:
		if stop_on_end:
			parent.stop()
		state_machine.dispatch("dash_stop")
