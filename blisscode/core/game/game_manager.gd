@tool
extends Node2D

@export var user_config: UserConfig
@export var game_config: GameConfig

@export_tool_button("Open User Folder", "Callable") var open_user_folder_action = open_user_folder
@export_tool_button("Remove User Data", "Callable") var remove_user_data_action = remove_user_data

signal paused_toggled(is_paused: bool)

func open_user_folder():
	var user_data_path = ProjectSettings.globalize_path("user://")
	OS.shell_open(user_data_path)

func remove_user_data():
	reset()

func _ready():
	call_deferred("_after_ready")
	
func _after_ready():
	if Engine.is_editor_hint():
		return
	# Connect signals
	EventBus.audio_volume_changed.connect(_on_audio_volume_changed)
	EventBus.world_changed.connect(_on_world_changed)
	
	# Audio
	set_audio_volumes()
	
	# Cursor
	set_custom_cursor()

	print("GameManager ready")

func set_custom_cursor():
	if user_config.custom_cursor_texture:
		Input.set_custom_mouse_cursor(user_config.custom_cursor_texture, Input.CURSOR_ARROW, Vector2(16, 16))

func set_audio_volumes():
	AudioUtils.set_volume(0, user_config.master_volume)
	AudioUtils.set_volume(1, user_config.music_volume)
	AudioUtils.set_volume(2, user_config.ambience_volume)
	AudioUtils.set_volume(3, user_config.effects_volume)

func _on_audio_volume_changed(bus_idx: int, volume: float):
	user_config.set_volume(bus_idx, volume)
	AudioUtils.set_volume(bus_idx, volume)
	user_config.save_to_file()

func set_zoom_level(zoom_level: float):
	user_config.zoom_level = zoom_level
	user_config.save_to_file()
	EventBus.zoom_level_changed.emit(zoom_level)

func _on_world_changed(to_room_id: String, from_room_id: String, _scene_path: String, _scene_transition_name: String):
	game_config.from_world_door_id = from_room_id
	game_config.to_world_door_id = to_room_id
	
func game_start():
	GameUi.game_menus.menu_stack.pop_all()
	SceneManager.goto_scene(GameManager.game_config.game_start_scene)

func game_restore():
	GameManager.game_config.set_state(GameConfig.GAME_STATE.GAME_RESTORE)
	GameUi.game_menus.menu_stack.pop_all()
	SceneManager.goto_scene(GameManager.game_config.game_restore_scene)

func reset():
	user_config.reset()
	game_config.reset()
	UserDataStore.reset()
	print("User data reset")

func print_config():
	print("UserConfig: ", user_config.save())
	print("GameConfig: ", game_config.save())

func get_user_config() -> UserConfig:
	return user_config

func get_game_config() -> GameConfig:
	return game_config

func pause():
	get_tree().paused = true
	paused_toggled.emit(true)

func toggle_pause():
	get_tree().paused = not get_tree().paused
	paused_toggled.emit(get_tree().paused)

func unpause():
	get_tree().paused = false
	paused_toggled.emit(get_tree().paused)

#Open your project in Godot and go to Project > Project Settings in the top menu.
#Click the Advanced Settings button at the top right of the Project Settings window to reveal all options.
#In the Project Settings window, navigate to Display > Window.
#Set Transparent to Enabled.
#Set Borderless to Enabled.
#Set Always on Top to Enabled.
#Navigate to Display > Window > Per Pixel Transparency.
#Set Allowed to Enabled.
#Navigate to Rendering > Viewport.
#Set Transparent Background to Enabled.
#(Optional) Set a fixed size for your game window under Display > Window > Size by adjusting the Width and Height. 
func transparent_window():
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)

func get_bottom_right_position() -> Vector2:
	var screen_size = DisplayServer.screen_get_size()
	var window_size = get_window().size
	return Vector2(screen_size.x - window_size.x, screen_size.y - window_size.y)

func set_window_position(pos: Vector2):
	# Set the window position.
	DisplayServer.window_set_position(pos)

func snap_to_grid(pos: Vector2) -> Vector2:
	var current_pos = pos
	var snapped_pos = Vector2(
		round(current_pos.x / game_config.grid_size) * game_config.grid_size,
		round(current_pos.y / game_config.grid_size) * game_config.grid_size
	)
	return snapped_pos

func reset_scene():
	get_tree().reload_current_scene()

func set_gravity_dir(dir: Vector2):
	game_config.set_gravity_dir(dir)

func toggle_anti_gravity() -> int:
	if game_config.gravity_dir == Vector2(0, 1):
		game_config.set_gravity_dir(Vector2(0, -1))
		return -1
	else:
		game_config.set_gravity_dir(Vector2(0, 1))
	return 1
