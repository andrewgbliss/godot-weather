class_name RigidBody2DAdvanced extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite2D

@export var health: int = 0
@export var max_health: int = 0
@export var armor: int = 0
@export var max_armor: int = 0
@export var spawn_on_ready: bool = false

@export_group("Drop")
@export var drop_pickup: PackedScene

@export_group("Garbage")
@export var garbage: bool = false
@export var garbage_time: float = 0.0

var is_paralyzed = false

signal spawned(pos: Vector2)
signal died(pos: Vector2)
signal health_changed(health_change: int, max_health: int)
signal armor_changed(armor_change: int, max_armor: int)

func _ready() -> void:
	health = max_health
	armor = max_armor
	if spawn_on_ready:
		spawn(position)

func spawn(pos: Vector2 = Vector2.ZERO):
	position = pos
	show()
	spawned.emit(global_position)
	is_paralyzed = false

func die():
	is_paralyzed = true
	if garbage:
		await get_tree().create_timer(garbage_time).timeout
		call_deferred("queue_free")
	else:
		await get_tree().create_timer(garbage_time).timeout
		hide()
	died.emit(global_position)
	if drop_pickup:
		var pickup = drop_pickup.instantiate()
		pickup.position = global_position
		get_tree().current_scene.add_child(pickup)

func take_damage(amount: int):
	if armor > 0:
		armor -= amount
		armor_changed.emit(armor, max_armor)
		return
	
	health -= amount

	_update_sprite_shader()

	if health <= 0:
		health_changed.emit(health, max_health)
		die()
		return
	
	health_changed.emit(health, max_health)

func _update_sprite_shader() -> void:
	if sprite:
		var health_percent = float(health) / float(max_health)
		var damage_amount = 100.0 - (health_percent * 100.0)
		sprite.material.set_shader_parameter("DamageAmount", damage_amount)
