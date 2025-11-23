extends Node

var from_scene_path = ""
var prev_door_id = ""
var current_door_id = ""
var restoring_scene = false

func save():
	var data = {
		"prev_door_id": prev_door_id,
		"current_door_id": current_door_id,
		"from_scene_path": from_scene_path,
		"restoring_scene": restoring_scene
	}
	return data

func restore(data):
	if data.has("prev_door_id"):
		prev_door_id = data["prev_door_id"]
	if data.has("current_door_id"):
		current_door_id = data["current_door_id"]
	if data.has("from_scene_path"):
		from_scene_path = data["from_scene_path"]
	if data.has("restoring_scene"):
		restoring_scene = data["restoring_scene"]

func reset():
	prev_door_id = ""
	current_door_id = ""
	from_scene_path = ""
	restoring_scene = false
