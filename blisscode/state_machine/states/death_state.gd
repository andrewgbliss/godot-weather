class_name DeathState extends AnimationState

func enter() -> void:
	parent.die(false)
	super.enter()

func process_frame(_delta: float) -> void:
	if is_animation_finished:
		parent.hide()
		dispatch()
