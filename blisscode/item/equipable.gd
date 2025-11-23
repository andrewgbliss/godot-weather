@tool
@abstract
class_name Equipable extends Item

enum EquipableSlotType {
	None,
	Helmet,
	Neck,
	Chest,
	Waist,
	Legs,
	Boots,
	Gloves,
	Finger,
	Hand
}

enum EquipableEffect {
	FIRE_DAMAGE,
	FROST_DAMAGE,
	HEALTH_REGEN,
	MANA_BOOST,
	CRITICAL_STRIKE,
	SPEED_INCREASE,
	POISON,
	DEFENSE_BOOST,
	ATTACK_BOOST,
	XP_GAIN
}

@export var weight: int = 0
@export var durability: int = 0
@export var sell_price: int = 0
@export var buy_price: int = 0
@export var level_requirement: int = 0
@export var slot: EquipableSlotType
@export var equip_on_pickup: bool = false
@export var effect: Array[EquipableEffect] = []

func get_slot_type(s: String):
	match s:
		"head":
			return EquipableSlotType.Helmet
		"neck":
			return EquipableSlotType.Neck
		"chest":
			return EquipableSlotType.Chest
		"waist":
			return EquipableSlotType.Waist
		"legs":
			return EquipableSlotType.Legs
		"feet":
			return EquipableSlotType.Boots
		"hands":
			return EquipableSlotType.Gloves
		"hand":
			return EquipableSlotType.Hand
		_:
			return EquipableSlotType.None

func save_slot_type(s: EquipableSlotType):
	match s:
		EquipableSlotType.Helmet:
			return "head"
		EquipableSlotType.Neck:
			return "neck"
		EquipableSlotType.Chest:
			return "chest"
		EquipableSlotType.Waist:
			return "waist"
		EquipableSlotType.Legs:
			return "legs"
		EquipableSlotType.Boots:
			return "feet"
		EquipableSlotType.Gloves:
			return "hands"
		EquipableSlotType.Hand:
			return "hand"
		_:
			return "none"

func save():
	var data = super.save()
	data["weight"] = weight
	data["durability"] = durability
	data["sell_price"] = sell_price
	data["buy_price"] = buy_price
	data["level_requirement"] = level_requirement
	data["slot"] = save_slot_type(slot)
	data["equip_on_pickup"] = equip_on_pickup
	data["effect"] = effect
	return data

func restore(data):
	super.restore(data)
	if data.has("weight"):
		weight = data["weight"]
	if data.has("durability"):
		durability = data["durability"]
	if data.has("sell_price"):
		sell_price = data["sell_price"]
	if data.has("buy_price"):
		buy_price = data["buy_price"]
	if data.has("level_requirement"):
		level_requirement = data["level_requirement"]
	if data.has("slot"):
		slot = get_slot_type(data["slot"])
	if data.has("equip_on_pickup"):
		equip_on_pickup = data["equip_on_pickup"]
	if data.has("effect"):
		effect = data["effect"]
