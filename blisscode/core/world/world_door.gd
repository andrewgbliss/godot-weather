class_name WorldDoor extends Area2D

@export var door_id: String
@export var goto_door_id: String
@export var scene_path: String
@export var spawn_position: SpawnPosition
@export var scene_transition_name: String = "Fade"
@export var entities_node: Node2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body is CharacterController:
		EventBus.world_changed.emit(goto_door_id, door_id, scene_path, scene_transition_name)

func spawn_player():
	if spawn_position:
		SpawnManager.spawn("player", spawn_position.global_position, entities_node)
