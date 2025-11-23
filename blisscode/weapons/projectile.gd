class_name Projectile extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var animation_name: String = "Fire"
@export var speed = 300
@export var damage = 1
@export var acceleration = 1
@export var follow_group_name: String
@export var time_to_live: float = 5.0

@export_category("Modifiers")
@export var gravity_percent: float = 0.0

@export_category("Collisions")
@export var destroy_on_collide: bool = true
@export var collide_effect: PackedScene
@export var blast_radius: float = 16.0

@export_category("Audio")
@export var audio: AudioStreamPlayer2D
@export_range(-100.0, 0) var min_audio_level: float = -10
@export_range(-100.0, 0) var max_audio_level: float = -5

var target: Node2D
var closest_target: Node2D
var has_given_damage = false
var velocity = Vector2.ZERO
var time_elapsed = 0

var current_weight
var angular_velocity

func _ready():
	if audio != null:
		var rand_level = randf_range(min_audio_level, max_audio_level)
		audio.volume_db = rand_level
		audio.play()
	if animation_player != null and animation_player.has_animation(animation_name):
		animation_player.play(animation_name)
	if follow_group_name:
		var targets = get_tree().get_nodes_in_group(follow_group_name)
		for t in targets:
			if not closest_target:
				closest_target = t
			else:
				var distance = t.global_position.distance_to(global_position)
				var closest_distance = closest_target.global_position.distance_to(global_position)
				if distance < closest_distance:
					closest_target = t
		if closest_target:
			target = closest_target
	time_elapsed = time_to_live
		
func _physics_process(delta):
	_apply_gravity(delta)
		
	if target != null and target.is_inside_tree():
		var direction = target.global_position - global_position
		
		velocity.x = move_toward(velocity.x, direction.normalized().x * speed, acceleration * delta)
		velocity.y = move_toward(velocity.y, direction.normalized().y * speed, acceleration * delta)

		rotation = velocity.angle()
	elif target != null and not target.is_inside_tree():
		target = null

	var collision = move_and_collide(velocity * delta)
	if collision:
		var body = collision.get_collider()
		
		if body is CharacterController:
			body.take_damage(damage)
				
		var body_parent = body.get_parent()
		if body_parent is Entity:
			body_parent.take_damage(damage)

		if body is TileMapLayerAdvanced:
			body.handle_collision(collision, blast_radius)

		if collide_effect != null:
			var collide_position = collision.get_position()
			var new_node = collide_effect.instantiate()
			new_node.global_position = collide_position
			get_tree().get_root().add_child(new_node)
			
		if destroy_on_collide:
			call_deferred("queue_free")
			
	time_elapsed -= delta
	if time_elapsed <= 0:
		call_deferred("queue_free")

func _apply_gravity(delta: float):
	velocity += get_gravity() * GameManager.game_config.gravity_dir.normalized() * gravity_percent * delta

func start(p, dir):
	position = p
	rotation = dir.angle()
	velocity = dir.normalized() * speed
