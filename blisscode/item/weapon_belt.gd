class_name WeaponBelt extends Resource

@export var weapons: Array[Weapon] = []

signal belt_slot_changed(slot: int, weapon: Weapon)

func set_belt_slot(slot: int, weapon: Weapon):
	if slot > 0 and slot <= weapons.size():
		weapons[slot] = weapon
		belt_slot_changed.emit(slot, weapon)

func set_next_belt_slot(weapon: Weapon):
	var next_empty_slot = weapons.find(null)
	if next_empty_slot == -1:
		return false
	set_belt_slot(next_empty_slot, weapon)
	return true

func get_slot(slot: int):
	if weapons.size() <= slot:
		return null
	return weapons[slot]

func save():
	var data = {
		"weapons": weapons.map(func(weapon): return weapon.save() if weapon else null),
	}
	return data

func restore(data):
	if data.has("weapons"):
		weapons = data["weapons"]

func swap_slots(from_index: int, to_index: int):
	weapons[from_index] = weapons[to_index]
	weapons[to_index] = weapons[from_index]
