class_name Spawner extends Node2D

@export var entity_name: String
@export var paths: Array[Path2D]
@export var entity_container: Node2D

func _ready():
	call_deferred("_after_ready")

func _after_ready():
	spawn()
	
func spawn():
	SpawnManager.spawn_paths(entity_name, global_position, paths, entity_container)
