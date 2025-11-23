class_name World extends Node2D

@export var world_name: String

var world_doors: Array[WorldDoor] = []

func _ready() -> void:
	_find_world_doors(self)
	call_deferred("_after_ready")

func _after_ready():
	if GameManager.game_config.game_state == GameConfig.GAME_STATE.GAME_RESTORE:
		_restore_spawn()
	else:
		_default_spawn()
	
	GameUi.hud.show_hud()
	
	#NotifcationsToast.show_notification("Game Ready", "Ready to start the game!")
	#NotifcationsToast.show_notification("Aint no one got you on this", "Holy shit!!!")
	
func _restore_spawn():
	UserDataStore.restore()
	GameManager.game_config.set_state(GameConfig.GAME_STATE.GAME_PLAY)
	
func _default_spawn():
	GameManager.game_config.set_state(GameConfig.GAME_STATE.GAME_PLAY)
	
func _find_world_doors(node: Node):
	if node is WorldDoor:
		world_doors.append(node)
	for child in node.get_children():
		_find_world_doors(child)

func find_world_door():
	for door in world_doors:
		if door.door_id == GameManager.game_config.to_world_door_id:
			return door
	return null

func save():
	return {
		"filename": get_scene_file_path(),
		"path": get_path(),
		"parent": get_parent().get_path(),
	}
