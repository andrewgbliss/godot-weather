class_name Equipment extends Resource

enum EquipmentSlotType {
	None,
	Helmet,
	Neck,
	Chest,
	Waist,
	Legs,
	Boots,
	Gloves,
	LeftFinger,
	RightFinger,
	LeftHand,
	RightHand
}

@export var head: Equipable
@export var neck: Equipable
@export var chest: Equipable
@export var waist: Equipable
@export var legs: Equipable
@export var feet: Equipable
@export var hand: Equipable
@export var left_finger: Equipable
@export var right_finger: Equipable
@export var left_hand: Equipable
@export var right_hand: Equipable

signal equipment_change

							
func equip(item: Item, equipment_slot_type: EquipmentSlotType):
	match equipment_slot_type:
		EquipmentSlotType.Helmet:
			head = item
		EquipmentSlotType.Neck:
			neck = item
		EquipmentSlotType.Chest:
			chest = item
		EquipmentSlotType.Waist:
			waist = item
		EquipmentSlotType.Legs:
			legs = item
		EquipmentSlotType.Boots:
			feet = item
		EquipmentSlotType.LeftHand:
			left_hand = item
		EquipmentSlotType.RightHand:
			right_hand = item
		EquipmentSlotType.LeftFinger:
			left_finger = item
		EquipmentSlotType.RightFinger:
			right_finger = item
	equipment_change.emit()
	
func unequip(equipment_slot_type: EquipmentSlotType):
	match equipment_slot_type:
		EquipmentSlotType.Helmet:
			head = null
		EquipmentSlotType.Neck:
			neck = null
		EquipmentSlotType.Chest:
			chest = null
		EquipmentSlotType.Waist:
			waist = null
		EquipmentSlotType.Legs:
			legs = null
		EquipmentSlotType.Boots:
			feet = null
		EquipmentSlotType.LeftHand:
			left_hand = null
		EquipmentSlotType.RightHand:
			right_hand = null
		EquipmentSlotType.LeftFinger:
			left_finger = null
		EquipmentSlotType.RightFinger:
			right_finger = null
	equipment_change.emit()

func get_slot_type(slot_type: Equipable.EquipableSlotType) -> EquipmentSlotType:
	if slot_type == Equipable.EquipableSlotType.Helmet:
		return EquipmentSlotType.Helmet
	if slot_type == Equipable.EquipableSlotType.Neck:
		return EquipmentSlotType.Neck
	if slot_type == Equipable.EquipableSlotType.Chest:
		return EquipmentSlotType.Chest
	if slot_type == Equipable.EquipableSlotType.Waist:
		return EquipmentSlotType.Waist
	if slot_type == Equipable.EquipableSlotType.Legs:
		return EquipmentSlotType.Legs
	if slot_type == Equipable.EquipableSlotType.Boots:
		return EquipmentSlotType.Boots
	if slot_type == Equipable.EquipableSlotType.Gloves:
		return EquipmentSlotType.Gloves
	if slot_type == Equipable.EquipableSlotType.Finger:
		return EquipmentSlotType.LeftFinger
	if slot_type == Equipable.EquipableSlotType.Finger:
		return EquipmentSlotType.RightFinger
	if slot_type == Equipable.EquipableSlotType.Hand:
		return EquipmentSlotType.LeftHand
	if slot_type == Equipable.EquipableSlotType.Hand:
		return EquipmentSlotType.RightHand
	return EquipmentSlotType.None


func save():
	var data = {
		"head": head,
		"neck": neck,
		"chest": chest,
		"waist": waist,
		"legs": legs,
		"feet": feet,
		"hand": hand,
		"left_finger": left_finger,
		"right_finger": right_finger,
		"left_hand": left_hand,
		"right_hand": right_hand
	}
	return data

func restore(data):
	if data.has("head"):
		head = data["head"]
	if data.has("neck"):
		neck = data["neck"]
	if data.has("chest"):
		chest = data["chest"]
	if data.has("waist"):
		waist = data["waist"]
	if data.has("legs"):
		legs = data["legs"]
	if data.has("feet"):
		feet = data["feet"]
	if data.has("hand"):
		hand = data["hand"]
	if data.has("left_finger"):
		left_finger = data["left_finger"]
	if data.has("right_finger"):
		right_finger = data["right_finger"]
	if data.has("left_hand"):
		left_hand = data["left_hand"]
	if data.has("right_hand"):
		right_hand = data["right_hand"]
