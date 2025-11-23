extends Node2D

@export var cutscene: PackedScene

func _ready() -> void:
	call_deferred("_after_ready")

func _after_ready():
	var cutscene_node = cutscene.instantiate()
	add_child(cutscene_node)
	cutscene_node.start()
	await get_tree().create_timer(5.0).timeout
	cutscene_node.stop()
	var restore_data = UserDataStore.get_restore_data()
	if not restore_data:
		print("No restore data")
	var restore_world_path = restore_data.world_data.filename
	SceneManager.goto_scene(restore_world_path)
