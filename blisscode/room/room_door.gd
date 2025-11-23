class_name RoomDoor extends Area2D

@export var to_room_door: RoomDoor
@export var spawn_position: SpawnPosition

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body is CharacterController:
		to_room_door.change_to_position(body)

func change_to_position(character: CharacterController):
	if spawn_position:
		character.change_to_position(spawn_position.global_position)
