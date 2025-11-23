class_name LedgeClimbState extends MoveState

func enter() -> void:
	super.enter()
	parent.flip_h_lock = true
	parent.stop()
	
func process_input(_event: InputEvent) -> void:
	pass

func process_physics(_delta: float) -> void:
	if is_animation_finished:
		state_machine.dispatch("idle")

func exit() -> void:
	super.exit()
	parent.flip_h_lock = false

  	# Calculate and warp to safe position above the ledge
	# When ledge grabbing, the raycast is NOT colliding (there's empty space = ledge)
	if parent.ledge_grab_raycast and parent.is_on_wall():
		# Get the wall collision to find where the ledge is
		var wall_collision = parent.get_last_slide_collision()
		if wall_collision:
			var wall_position = wall_collision.get_position()
			
			# Use the raycast's target position to estimate ledge height
			# The raycast is positioned to shoot upward/forward from the player
			var raycast_global_pos = parent.ledge_grab_raycast.global_position
			var raycast_target = parent.ledge_grab_raycast.target_position
			var raycast_end_pos = raycast_global_pos + raycast_target
			
			# The ledge top is approximately at the raycast's end position Y
			var ledge_top_y = raycast_end_pos.y
			var ledge_x = wall_position.x
			
			# Tiles are 16x16, so use fixed dimensions for horizontal positioning
			var tile_width = 16.0
			
			# Get player collision shape dimensions
			var collision_shape = parent.collision_shape
			var player_height = 0.0
			if collision_shape and collision_shape.shape:
				var shape = collision_shape.shape
				if shape is RectangleShape2D:
					player_height = shape.size.y
				elif shape is CapsuleShape2D:
					player_height = shape.height + shape.radius * 2
				elif shape is CircleShape2D:
					player_height = shape.radius * 2
			
			# Calculate safe position above the ledge
			# Position the player so the bottom of collision is slightly above the ledge top
			var safe_y_offset = player_height / 2.0 + 2.0
			var safe_position = Vector2(ledge_x, ledge_top_y - safe_y_offset)
			
			# Adjust horizontal position to move away from the wall edge
			# Use tile width for horizontal positioning
			var horizontal_offset = tile_width / 2.0 + 4.0
			if parent.is_facing_right:
				safe_position.x += horizontal_offset
			else:
				safe_position.x -= horizontal_offset
			
			# Warp the player to the safe position
			parent.global_position = safe_position
