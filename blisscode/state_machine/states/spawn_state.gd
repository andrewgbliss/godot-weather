class_name SpawnState extends AnimationState

func enter() -> void:
	parent.spawn()
	super.enter()

func process_frame(_delta: float) -> void:
	if is_animation_finished:
		dispatch()
