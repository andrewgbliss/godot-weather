@tool
class_name MeleeWeapon extends Weapon

func save():
	var data = super.save()
	return data

func restore(data):
	super.restore(data)
