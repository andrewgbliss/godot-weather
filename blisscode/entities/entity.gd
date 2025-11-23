class_name Entity extends Node2D

@export var entity_sheet: EntitySheet

@export_group("Drop")
@export var drop_pickup: PackedScene

@export_group("Garbage")
@export var garbage: bool = false
@export var garbage_time: float = 0.0

@export var sprite: Sprite2D

var is_paralyzed = false

signal spawned(pos: Vector2)
signal died(pos: Vector2)
signal health_changed(health_change: int, max_health: int)
signal armor_changed(armor_change: int, max_armor: int)

func _ready() -> void:
	entity_sheet = entity_sheet.duplicate()

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
	# Armor absorbs damage
	if entity_sheet.armor > 0:
		entity_sheet.armor -= amount
		armor_changed.emit(entity_sheet.armor, entity_sheet.max_armor)
		return
	
	entity_sheet.health -= amount

	_update_sprite_shader()

	# Check for death
	if entity_sheet.health <= 0:
		health_changed.emit(entity_sheet.health, entity_sheet.max_health)
		die()
		return
	
	# Emit current health
	health_changed.emit(entity_sheet.health, entity_sheet.max_health)

func _update_sprite_shader() -> void:
	if sprite:
		var health_percent = float(entity_sheet.health) / float(entity_sheet.max_health)
		var damage_amount = 100.0 - (health_percent * 100.0)
		sprite.material.set_shader_parameter("DamageAmount", damage_amount)
