class_name Hitbox extends Area2D

enum KnockbackDirection {
	NONE,
	UP,
	DOWN,
	SIDE
}

@export var damage: int = 1
@export var facing_left_position: Vector2 = Vector2.ZERO
@export var facing_right_position: Vector2 = Vector2.ZERO
@export var animated_sprite: AnimatedSprite2D
@export var knockback_direction: KnockbackDirection = KnockbackDirection.NONE
@export var collide_effect: PackedScene

var parent

func _ready() -> void:
	parent = get_parent()
	body_entered.connect(_on_body_entered)

func _process(_delta: float) -> void:
	if animated_sprite:
		if animated_sprite.flip_h:
			position = facing_left_position
		else:
			position = facing_right_position

func _on_body_entered(body: Node2D) -> void:
	var collide_position = get_collision_point(body)
	if collide_effect:
		var effect = collide_effect.instantiate()
		effect.global_position = collide_position
		get_tree().current_scene.add_child(effect)

	var direction = Vector2.ZERO
	if knockback_direction == KnockbackDirection.UP:
		direction = Vector2.UP
	elif knockback_direction == KnockbackDirection.DOWN:
		direction = Vector2.DOWN
	elif knockback_direction == KnockbackDirection.SIDE:
		if parent.is_facing_right:
			direction = Vector2.LEFT
		else:
			direction = Vector2.RIGHT

	if body is CharacterController:
		body.take_damage(damage)
		if knockback_direction != KnockbackDirection.NONE:
			body.apply_knockback(direction)
	if body is RigidBody2DAdvanced:
		var body_parent = body.get_parent()
		if body_parent is Entity:
			body_parent.take_damage(damage)
			apply_knockback_rigid(body)
			if knockback_direction != KnockbackDirection.NONE:
				parent.apply_knockback(direction)
	if body is TileMapLayerAdvanced:
		if knockback_direction != KnockbackDirection.NONE:
			parent.apply_knockback(direction)

func get_collision_point(body) -> Vector2:
	# Calculate the contact point between hitbox and body
	# This is the point on our hitbox edge closest to the body
	var direction_to_body = (body.global_position - global_position).normalized()
	
	# Get our collision shape to determine the edge point
	var collision_shape = null
	for child in get_children():
		if child is CollisionShape2D:
			collision_shape = child
			break
	
	if not collision_shape:
		# Fallback: midpoint between centers
		return (global_position + body.global_position) / 2.0
	
	# Calculate approximate edge point based on shape
	var shape_resource = collision_shape.shape
	var edge_offset = Vector2.ZERO
	
	if shape_resource is CircleShape2D:
		edge_offset = direction_to_body * shape_resource.radius
	elif shape_resource is RectangleShape2D:
		var extents = shape_resource.size / 2.0
		edge_offset.x = clamp(direction_to_body.x * extents.x * 1.5, -extents.x, extents.x)
		edge_offset.y = clamp(direction_to_body.y * extents.y * 1.5, -extents.y, extents.y)
	elif shape_resource is CapsuleShape2D:
		edge_offset = direction_to_body * shape_resource.radius
	else:
		# Unknown shape, use simple midpoint
		return (global_position + body.global_position) / 2.0
	
	return global_position + collision_shape.position + edge_offset

func apply_knockback_rigid(rigidbody: RigidBody2D) -> void:
	# Direction AWAY from hitbox - flip it
	var direction = (rigidbody.global_position - global_position).normalized()
	var impulse = direction * parent.character.knockback_force * 2.0
	# print("Knockback direction: ", direction, " impulse: ", impulse)
	rigidbody.apply_central_impulse(impulse)
