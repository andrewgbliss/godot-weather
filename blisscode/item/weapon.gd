@tool
@abstract
class_name Weapon extends Equipable

@export var damage_min: int = 0
@export var damage_max: int = 0
@export var attack_rate: float = 0.0
@export var stamina_cost: float = 0.0

func save():
	var data = super.save()
	data["damage_min"] = damage_min
	data["damage_max"] = damage_max
	data["attack_rate"] = attack_rate
	data["stamina_cost"] = stamina_cost
	return data

func restore(data):
	super.restore(data)
	if data.has("damage_min"):
		damage_min = data["damage_min"]
	if data.has("damage_max"):
		damage_max = data["damage_max"]
	if data.has("attack_rate"):
		attack_rate = data["attack_rate"]
	if data.has("stamina_cost"):
		stamina_cost = data["stamina_cost"]
