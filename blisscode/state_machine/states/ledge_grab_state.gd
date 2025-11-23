class_name LedgeGrabState extends MoveState

@export var hand_offset: Vector2 = Vector2.ZERO

func enter() -> void:
	super.enter()
	parent.flip_h_lock = true
	parent.stop()
	
	if parent.ledge_grab_raycast and parent.is_on_wall():
		var raycast: RayCast2D = parent.ledge_grab_raycast
		if not raycast.is_colliding():
			var raycast_end_pos = raycast.to_global(raycast.target_position)
			var wall_collision = parent.get_last_slide_collision()
			
			var tile_size = 16.0
			var half_tile = tile_size / 2.0
			var wall_buffer = half_tile + 2.0
			
			var hang_position: Vector2
			if wall_collision:
				var contact_point = wall_collision.get_position()
				var wall_normal = wall_collision.get_normal()
				hang_position = contact_point + wall_normal * wall_buffer
			else:
				var facing_sign = 1.0 if parent.is_facing_right else -1.0
				hang_position = Vector2(raycast_end_pos.x - facing_sign * wall_buffer, parent.global_position.y)
			
			hang_position.y = raycast_end_pos.y + half_tile
			parent.global_position = hang_position + hand_offset

func process_input(event: InputEvent) -> void:
	if parent.paralyzed:
		return
	if event.is_action_pressed("jump"):
		state_machine.dispatch("ledge_climb")

func process_physics(_delta: float) -> void:
	if is_animation_finished:
		state_machine.dispatch("ledge_climb")
		return

func exit() -> void:
	super.exit()
	parent.flip_h_lock = false
