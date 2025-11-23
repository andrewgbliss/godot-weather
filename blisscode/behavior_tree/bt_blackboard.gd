class_name BTBlackboard extends Node

var data: Dictionary = {}

func set_var(key: String, value: Variant):
	data[key] = value

func get_var(key: String, default_value: Variant = null) -> Variant:
	return data.get(key, default_value)
	
func has_var(key: String) -> bool:
	return data.has(key)

func remove_var(key: String):
	data.erase(key)

func get_data():
	return data

func save():
	return data

func restore(new_data):
	data = new_data
