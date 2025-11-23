class_name DamageState extends AnimationState

func process_frame(delta: float) -> void:
	parent.move(Vector2.ZERO, delta)
	if is_animation_finished:
		dispatch()
