@tool
class_name Consumable extends Item

@export var health: int = 0
@export var mana: int = 0
@export var stamina: int = 0
@export var consume_on_pickup: bool = false

func save():
	var data = super.save()
	data["health"] = health
	data["mana"] = mana
	data["stamina"] = stamina
	data["consume_on_pickup"] = consume_on_pickup
	return data

func restore(data):
	super.restore(data)
	if data.has("health"):
		health = data["health"]
	if data.has("mana"):
		mana = data["mana"]
	if data.has("stamina"):
		stamina = data["stamina"]
	if data.has("consume_on_pickup"):
		consume_on_pickup = data["consume_on_pickup"]
