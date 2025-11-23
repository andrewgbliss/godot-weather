@tool
class_name RangedWeapon extends Weapon

@export var projectile: String = ""
@export var max_ammo: int = 0
@export var unlimited_ammo: bool = false
@export var ammo: int = 0
@export var spread: int = 1
@export var spread_angle: float = 0.3
@export var screen_shake_amount: float = 0.0

func save():
	var data = super.save()
	data["projectile"] = projectile
	data["max_ammo"] = max_ammo
	data["unlimited_ammo"] = unlimited_ammo
	data["ammo"] = ammo
	data["spread"] = spread
	data["spread_angle"] = spread_angle
	data["screen_shake_amount"] = screen_shake_amount
	return data

func restore(data):
	super.restore(data)
	if data.has("projectile"):
		projectile = data["projectile"]
	if data.has("max_ammo"):
		max_ammo = data["max_ammo"]
	if data.has("unlimited_ammo"):
		unlimited_ammo = data["unlimited_ammo"]
	if data.has("ammo"):
		ammo = data["ammo"]
	if data.has("spread"):
		spread = data["spread"]
	if data.has("spread_angle"):
		spread_angle = data["spread_angle"]
	if data.has("screen_shake_amount"):
		screen_shake_amount = data["screen_shake_amount"]
