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
	GameManager.game_config.set_state(GameConfig.GAME_STATE.GAME_PLAY)
	SceneManager.goto_scene(GameManager.game_config.default_world_path)
