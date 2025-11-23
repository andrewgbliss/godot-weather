class_name MoveState extends AnimationState

func process_input(event: InputEvent) -> void:
	if parent.paralyzed:
		return
	elif event.is_action_pressed("dash"):
		state_machine.dispatch("dash")
	elif event.is_action_pressed("jump"):
		state_machine.dispatch("jump")
	elif event.is_action_pressed("change_gravity_dir"):
		GameManager.toggle_anti_gravity()
	elif event.is_action_pressed("smash_down"):
		state_machine.dispatch("smash_down")
	elif event.is_action_pressed("roll") and parent.is_on_floor():
		state_machine.dispatch("roll")
	elif event.is_action_pressed("attack_left_hand") or event.is_action_pressed("attack_right_hand"):
		attack()

func process_physics(delta: float) -> void:
	var direction = parent.controls.get_movement_direction()
	parent.move(direction, delta)

func attack():
	if parent.controls.is_attacking_left_hand():
		state_machine.shared_data["hand_direction"] = "left"
		state_machine.dispatch("attack")
	if parent.controls.is_attacking_right_hand():
		state_machine.shared_data["hand_direction"] = "right"
		state_machine.dispatch("attack")
