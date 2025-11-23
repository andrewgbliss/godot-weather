class_name CharacterController extends CharacterBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera2D

@export var character: Character
@export var controls: CharacterControls
@export var state_machine: StateMachine

@export_group("Navigation")
@export var navigation_agent: NavigationAgent2D
@export var paths: Array[Path2D]

@export_group("Garbage")
@export var garbage: bool = false
@export var garbage_time: float = 0.0

@export_group("Behavior Trees")
@export var behavior_trees: Array[BTPlayer] = []

@export_group("Abilities")
@export var dangling_raycast: RayCast2D
@export var ladder_raycast: RayCast2D
@export var ledge_grab_raycast: RayCast2D

var is_alive = false
var is_facing_right = true
var paralyzed: bool = false
var original_speed: float
var time_scale: float = 1.0
var gravity_dir: Vector2 = Vector2(0, 1)
var default_gravity_dir: Vector2 = Vector2(0, 1)
var spawn_position: Vector2 = Vector2.ZERO
var flip_v_lock: bool = false
var flip_h_lock: bool = false
var wall_cling_point: Vector2 = Vector2.ZERO
var current_tilemap_collider: TileMapLayerAdvanced

signal spawned(pos: Vector2)
signal died(character: CharacterController)
signal facing_direction_changed

func _ready() -> void:
	hide()
	paralyzed = true
	GameManager.game_config.gravity_dir_changed.connect(_on_gravity_dir_changed)
	if navigation_agent:
		navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func _on_gravity_dir_changed(dir: Vector2):
	gravity_dir = dir

func move(direction: Vector2, delta: float, resolve: bool = false) -> bool:
	velocity += apply_gravity(delta)

	var physics = character.get_physics_group()
	
	if not paralyzed:
		if not physics.has_navigation:
			if controls.is_pressing_down() and controls.is_walking():
				physics.speed = original_speed * physics.crouch_multiplier
			elif controls.is_walking():
				physics.speed = original_speed * physics.walk_multiplier
			elif controls.is_running():
				physics.speed = original_speed * physics.run_multiplier
				time_scale = physics.run_multiplier
			else:
				physics.speed = original_speed
				time_scale = 1.0

			velocity = self.move_toward(direction, physics.speed * physics.movement_percent)

	clamp_velocity()

	if move_and_slide():
		handle_collisions(resolve)
		return true

	if current_tilemap_collider:
		character.reset_physics_group_override()
		current_tilemap_collider = null

	return false

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	clamp_velocity()
		
func change_to_position(new_position: Vector2 = Vector2.ZERO):
	position = new_position
	
func apply_gravity(delta: float):
	var physics = character.get_physics_group()
	return get_gravity() * gravity_dir.normalized() * physics.gravity_percent * delta

func move_toward(direction: Vector2, s: float):
	var physics = character.get_physics_group()
	var result_velocity = velocity
	
	if physics.movement_lerp:
		if direction != Vector2.ZERO:
			# Calculate target velocity using the whole direction vector
			var target_velocity = direction * s * physics.movement_percent
			if not physics.allow_y_controls:
				# Only preserve vertical velocity (gravity) if y controls are disabled
				target_velocity.y = velocity.y
			result_velocity = result_velocity.move_toward(target_velocity, physics.acceleration)
		else:
			# Apply friction, preserving vertical velocity if y controls are disabled
			var target_velocity = Vector2.ZERO
			if not physics.allow_y_controls:
				target_velocity.y = velocity.y
			result_velocity = result_velocity.move_toward(target_velocity, physics.friction)
	else:
		if direction != Vector2.ZERO:
			result_velocity = direction * s * physics.movement_percent
			if not physics.allow_y_controls:
				result_velocity.y = velocity.y
		else:
			result_velocity = Vector2.ZERO
			if not physics.allow_y_controls:
				result_velocity.y = velocity.y
	return result_velocity
		
func clamp_velocity():
	var physics = character.get_physics_group()
	velocity = velocity.clamp(-physics.max_velocity, physics.max_velocity)
							
func stop():
	velocity = Vector2.ZERO

func attack_momentum():
	var physics = character.get_physics_group()
	var direction = controls.get_facing_direction()
	velocity.x += direction.x * physics.speed * physics.attack_momentum_multiplier
	return direction

func dash():
	var physics = character.get_physics_group()
	var direction = Vector2.ZERO
	if controls.double_tap_direction != controls.DOUBLE_TAP_DIRECTION.NONE:
		direction = controls.get_double_tap_direction()
		controls.double_tap_direction = controls.DOUBLE_TAP_DIRECTION.NONE
	else:
		direction = controls.get_aim_direction()
	stop()
	velocity += direction * physics.speed * physics.dash_speed_multiplier
	return direction

func roll():
	var physics = character.get_physics_group()
	var direction = controls.get_facing_direction()
	velocity.x += direction.x * physics.speed * physics.roll_speed_multiplier
	return direction

func slide():
	var physics = character.get_physics_group()
	var direction = controls.get_aim_direction()
	direction.y = 0.0
	velocity += direction * physics.speed * physics.slide_speed_multiplier
	return direction

func jump():
	var physics = character.get_physics_group()
	velocity.y = - physics.jump_force * GameManager.game_config.gravity_dir.y

func wall_jump():
	var physics = character.get_physics_group()
	var direction = 0
	if wall_cling_point.x > global_position.x:
		direction = 1
	else:
		direction = -1
	velocity.y = - physics.jump_force * GameManager.game_config.gravity_dir.y
	velocity.x = physics.jump_force * 2.0 * GameManager.game_config.gravity_dir.x * -direction
	wall_cling_point = Vector2.ZERO

func is_falling():
	return velocity.y > 0 and not is_on_floor()

func is_dangling():
	if dangling_raycast:
		return not dangling_raycast.is_colliding() and is_on_floor()
	return false

func is_on_ladder():
	if ladder_raycast:
		return ladder_raycast.is_colliding()
	return false

func is_on_land():
	var is_land = is_on_floor()
	if is_land:
		var collision = get_last_slide_collision()
		if collision:
			var collider = collision.get_collider()
			if collider is TileMapLayerAdvanced:
				return false
	return false

func is_wall_clinging():
	if is_on_wall():
		if not character.get_physics_group().require_input_direction:
			return true
		var collision = get_last_slide_collision()
		if collision:
			var collider = collision.get_collider()
			if collider is TileMapLayerAdvanced:
				wall_cling_point = collision.get_position()
				var colliision_right = wall_cling_point.x > global_position.x
				if controls.is_pressing_right() and colliision_right:
					return wall_cling_point
				elif controls.is_pressing_left() and not colliision_right:
					return wall_cling_point
	return null

func is_ledge_grabbing():
	if ledge_grab_raycast:
		if not ledge_grab_raycast.is_colliding():
			if is_on_wall():
					if controls.is_pressing_right() and is_facing_right:
						return true
					elif controls.is_pressing_left() and not is_facing_right:
						return true
	return false

func is_smashing_down():
	if controls.is_attacking_left_hand() and controls.is_pressing_down():
		return true
	return false

func set_flip_to_input_direction():
	if controls.is_pressing_right():
		animated_sprite.flip_h = false
	elif controls.is_pressing_left():
		animated_sprite.flip_h = true

func handle_collisions(resolve: bool = false):
	var physics = character.get_physics_group()
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		
		if resolve:
			_resolve_collision(col)
		
		var collider = col.get_collider()
					
		if collider is RigidBody2D:
			collider.apply_central_impulse(col.get_normal() * -physics.push_force)

		if collider is TileMapLayerAdvanced:
			if state_machine.current_state.freeze_physics:
				return
			if current_tilemap_collider != collider:
				current_tilemap_collider = collider
				if collider.physics_group_override:
					character.set_physics_group_override(collider.physics_group_override)
				else:
					character.reset_physics_group_override()

func _resolve_collision(collision):
	var normal = collision.get_normal()
	var depth = collision.get_depth()
	var travel = collision.get_travel()

	# Calculate the movement needed to resolve the collision
	var move_amount = normal * depth

	# Adjust position considering the original travel direction (optional)
	global_position += move_amount + (travel * 0.1) # Adjust the factor as needed

func apply_knockback(direction: Vector2):
	var physics = character.get_physics_group()
	stop()
	var knockback_force = direction * physics.knockback_force
	velocity += knockback_force
	
func face_direction(_direction: Vector2):
	# TODO - This is for npc's that want to look at the character move
	pass


func item_pickup(item: Item, pos: Vector2):
	if item is Currency:
		character.inventory.add_gold(item)
	elif item is Equipable:
		equip(item, pos)
	elif item is Consumable:
		consume(item, pos)

func consume(item: Item, _pos: Vector2):
	if item.consume_on_pickup:
		if item.health > 0:
			character.character_sheet.add_health(item.health)
		if item.mana > 0:
			character.character_sheet.add_mana(item.mana)
		if item.stamina > 0:
			character.character_sheet.add_stamina(item.stamina)
	else:
		character.inventory.add(item)

func equip(item: Item, _pos: Vector2):
	if item.equip_on_pickup:
		character.weapon_belt.set_next_belt_slot(item)
		character.equipment.equip(item, character.equipment.get_slot_type(item.slot))
	else:
		character.inventory.add(item)

func focus():
	if camera:
		camera.enabled = true
		camera.make_current()

func spawn():
	var physics = character.get_physics_group()
	is_alive = true
	if physics:
		original_speed = physics.speed
	if material:
		material.set_shader_parameter("teleport_progress", 0.0)
		material.set_shader_parameter("pulse_mode", 0)
		material.set_shader_parameter("pulse_cycle_speed", 1.0)
	velocity = Vector2.ZERO
	paralyzed = false
	position = spawn_position
	character.character_sheet.spawn_reset()
	show()
	focus()
	spawned.emit(global_position)
	
func spawn_random_from_nav():
	if navigation_agent:
		var map = navigation_agent.get_navigation_map()
		if map == null:
			return
		spawn_position = NavigationServer2D.map_get_random_point(map, 1, false)
		spawn()
	else:
		spawn()
		
func paralyze():
	paralyzed = true
	velocity = Vector2.ZERO

func die(hide_after: bool = true):
	is_alive = false
	died.emit(self)
	paralyzed = true
	if garbage:
		await get_tree().create_timer(garbage_time).timeout
		call_deferred("queue_free")
	else:
		await get_tree().create_timer(garbage_time).timeout
		if hide_after:
			hide()

func flip_h():
	animated_sprite.flip_h = not is_facing_right
	facing_direction_changed.emit()

func take_damage(amount: int):
	if not is_alive:
		return
	if state_machine:
		state_machine.dispatch("damage")
	character.character_sheet.take_damage(amount)
	pulse_health()
	if character.character_sheet.health <= 0:
		if state_machine:
			state_machine.dispatch("death")

func pulse_health():
	if not is_alive:
		return
	if material:
		# One shot
		material.set_shader_parameter("pulse_mode", 1)
		material.set_shader_parameter("pulse_cycle_speed", 10.0)
		await get_tree().create_timer(0.5).timeout
		material.set_shader_parameter("pulse_mode", 0)
		material.set_shader_parameter("pulse_cycle_speed", 1.0)

	  # Continuous
		var health_percent = float(character.character_sheet.health) / float(character.character_sheet.max_health)
		if health_percent < 0.5:
			var pulse_cycle_speed = health_percent * 10.0
			material.set_shader_parameter("pulse_mode", 1)
			material.set_shader_parameter("pulse_cycle_speed", pulse_cycle_speed)
		else:
			material.set_shader_parameter("pulse_mode", 0)
			material.set_shader_parameter("pulse_cycle_speed", 1.0)


func save():
	var behavior_trees_data = []
	for tree in behavior_trees:
		behavior_trees_data.append(tree.save())
	var path_progress_ratios = []
	for path in paths:
		var follow = path.get_node("PathFollow2D")
		path_progress_ratios.append(follow.progress_ratio)
	var data = {
		"filename": get_scene_file_path(),
		"path": get_path(),
		"parent": get_parent().get_path(),
		"pos_x": position.x,
		"pos_y": position.y,
		"rotation": rotation,
		"velocity_x": velocity.x,
		"velocity_y": velocity.y,
		"behavior_trees": behavior_trees_data,
		"path_progress_ratios": path_progress_ratios,
		"spawn_position_x": spawn_position.x,
		"spawn_position_y": spawn_position.y,
		"is_facing_right": is_facing_right,
		#"character_sheet": character_sheet.save(),
		#"inventory": inventory.save()
	}
	return data
	
func restore(data):
	if data.has("pos_x"):
		position.x = data.get("pos_x")
	if data.has("pos_y"):
		position.y = data.get("pos_y")
	if data.has("rotation"):
		rotation = data.get("rotation")
	if data.has("velocity_x"):
		velocity.x = data.get("velocity_x")
	if data.has("velocity_y"):
		velocity.y = data.get("velocity_y")
	if data.has("behavior_trees"):
		for tree_data in data.get("behavior_trees"):
			for tree in behavior_trees:
				tree.restore(tree_data)
	if data.has("path_progress_ratios"):
		for path_data in data.get("path_progress_ratios"):
			for path in paths:
				var follow = path.get_node("PathFollow2D")
				follow.progress_ratio = path_data
	if data.has("spawn_position_x"):
		spawn_position.x = data.get("spawn_position_x")
	if data.has("spawn_position_y"):
		spawn_position.y = data.get("spawn_position_y")
	if data.has("is_facing_right"):
		is_facing_right = data.get("is_facing_right")
	#if data.has("character_sheet"):
		#character_sheet.restore(data.get("character_sheet"))
	#if data.has("inventory"):
		#inventory.restore(data.get("inventory"))
