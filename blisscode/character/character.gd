class_name Character extends Resource

@export var character_sheet: CharacterSheet
@export var inventory: Inventory
@export var equipment: Equipment
@export var weapon_belt: WeaponBelt
@export var physics_group: PhysicsGroup
@export var physics_group_override: PhysicsGroup

signal physics_group_override_changed

func set_physics_group_override(group: PhysicsGroup) -> void:
	physics_group_override = group
	physics_group_override_changed.emit()

func get_physics_group() -> PhysicsGroup:
	if physics_group_override:
		return physics_group_override
	return physics_group

func reset_physics_group_override() -> void:
	physics_group_override = null
	physics_group_override_changed.emit()
