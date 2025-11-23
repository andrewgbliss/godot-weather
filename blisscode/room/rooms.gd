class_name Rooms extends Node2D

var rooms: Array[Room] = []
var room_doors: Array[RoomDoor] = []

func _ready() -> void:
	_find_rooms(self)
	_find_room_doors(self)

func _find_rooms(node: Node):
	if node is Room:
		rooms.append(node)
	for child in node.get_children():
		_find_rooms(child)

func _find_room_doors(node: Node):
	if node is RoomDoor:
		room_doors.append(node)
	for child in node.get_children():
		_find_room_doors(child)

func get_room_by_id(id: String) -> Room:
	for room in rooms:
		if room.room_id == id:
			return room
	return null
