@tool
class_name GameConfig extends Resource

enum GAME_STATE {
	NONE,
	INIT_LOAD,
	SPLASH_SCREENS,
	GAME_MENU,
	GAME_PLAY,
	GAME_SAVE,
	GAME_RESTORE,
	GAME_PAUSED,
	GAME_OVER,
	GAME_VICTORY
}

@export var game_state: GAME_STATE = GAME_STATE.NONE
@export var game_start_scene: String = "res://scenes/game_start.tscn"
@export var game_restore_scene: String = "res://scenes/game_restore.tscn"
@export var default_world_path: String = "res://scenes/world/world.tscn"
@export var grid_size: int = 16
@export var gravity_dir: Vector2 = Vector2(0, 1)

var from_world_door_id: String = ""
var to_world_door_id: String = ""

signal state_changed(state: GAME_STATE)
signal gravity_dir_changed(dir: Vector2)
		
func _init():
	init_restore()

func set_gravity_dir(dir: Vector2):
	if dir != gravity_dir:
		gravity_dir = dir
		gravity_dir_changed.emit(gravity_dir)

func set_state(new_game_state: GAME_STATE):
	if new_game_state != game_state:
		game_state = new_game_state
		state_changed.emit(game_state)

func save():
	return {
		"game_state": game_state,
		"game_start_scene": game_start_scene
	}

func restore(data):
	if data.has("game_state"):
		game_state = data["game_state"]
	if data.has("game_start_scene"):
		game_start_scene = data["game_start_scene"]

func init_restore():
	var data = FilesUtil.restore_or_create("user://game_config.json", save())
	if data != null:
		restore(data)

func save_to_file():
	FilesUtil.save("user://game_config.json", save())

func reset():
	game_state = GAME_STATE.NONE
	game_start_scene = "res://scenes/game_start.tscn"
	save_to_file()
