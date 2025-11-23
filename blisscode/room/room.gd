class_name Room extends Node2D

@export var room_id: String = ""

var room_doors = []
var world_doors = []

func _ready() -> void:
	_find_room_doors(self)
	_find_world_doors(self)

func get_room_door_by_id(id: String) -> RoomDoor:
	for door in room_doors:
		if door.door_id == id:
			return door
	return null

func get_world_door_by_id(id: String) -> WorldDoor:
	for door in world_doors:
		if door.door_id == id:
			return door
	return null

func _find_room_doors(node: Node):
	if node is RoomDoor:
		room_doors.append(node)
	for child in node.get_children():
		_find_room_doors(child)

func _find_world_doors(node: Node):
	if node is WorldDoor:
		world_doors.append(node)
	for child in node.get_children():
		_find_world_doors(child)
