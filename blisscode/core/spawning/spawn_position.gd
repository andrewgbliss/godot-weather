class_name SpawnPosition extends Node2D

func save():
	var data = {
		"position": global_position
	}
	return data

func restore(data):
	global_position = data["position"]
