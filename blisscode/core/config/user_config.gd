@tool
class_name UserConfig extends Resource

@export_group("Cursor")
@export var custom_cursor_texture: Texture2D

enum AimType {DEFAULT, MOUSE, KEYBOARD, JOYSTICK, TOUCH, AI}
enum MovementType {DEFAULT, MOUSE, KEYBOARD, JOYSTICK, TOUCH, AI}
enum FacingType {DEFAULT, MOUSE, KEYBOARD, JOYSTICK, TOUCH, AI}
enum AttackType {DEFAULT, MOUSE, KEYBOARD, JOYSTICK, TOUCH, AI}

@export_group("Input Type")
@export var movement_type: MovementType = MovementType.DEFAULT
@export var aim_type: AimType = AimType.DEFAULT
@export var facing_type: FacingType = FacingType.DEFAULT
@export var attack_type: AttackType = AttackType.DEFAULT

@export_group("Zoom")
@export var zoom_level: float = 1.0

var master_volume: float = 50.0
var music_volume: float = 50.0
var ambience_volume: float = 50.0
var effects_volume: float = 50.0

# Key bindings storage
var custom_key_bindings: Dictionary = {}

@export_tool_button("Mobile", "Callable") var mobile_action = mobile_controls

func mobile_controls():
	aim_type = AimType.TOUCH
	movement_type = MovementType.TOUCH
	facing_type = FacingType.TOUCH
	attack_type = AttackType.TOUCH

@export_tool_button("Console", "Callable") var console_action = console_controls

func console_controls():
	aim_type = AimType.JOYSTICK
	movement_type = MovementType.JOYSTICK
	facing_type = FacingType.JOYSTICK
	attack_type = AttackType.JOYSTICK

@export_tool_button("PC", "Callable") var pc_action = pc_controls

func pc_controls():
	aim_type = AimType.MOUSE
	movement_type = MovementType.KEYBOARD
	facing_type = FacingType.MOUSE
	attack_type = AttackType.MOUSE

signal loaded

func _init():
	call_deferred("_after_init")
	
func _after_init():
	init_restore()
	# print_config()

func get_volume(bus_idx: int) -> float:
	match bus_idx:
		0: return master_volume
		1: return music_volume
		2: return ambience_volume
		3: return effects_volume
	return 0.0

func set_volume(bus_idx: int, volume: float):
	match bus_idx:
		0: master_volume = volume
		1: music_volume = volume
		2: ambience_volume = volume
		3: effects_volume = volume

func save():
	return {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"ambience_volume": ambience_volume,
		"effects_volume": effects_volume,
		"movement_type": movement_type,
		"aim_type": aim_type,
		"facing_type": facing_type,
		"attack_type": attack_type,
		"custom_key_bindings": custom_key_bindings,
		"zoom_level": zoom_level
	}

func restore(data):
	if data.has("master_volume"):
		master_volume = data["master_volume"]
	if data.has("music_volume"):
		music_volume = data["music_volume"]
	if data.has("ambience_volume"):
		ambience_volume = data["ambience_volume"]
	if data.has("effects_volume"):
		effects_volume = data["effects_volume"]
	if data.has("movement_type"):
		match int(data["movement_type"]):
			0: movement_type = MovementType.DEFAULT
			1: movement_type = MovementType.MOUSE
			2: movement_type = MovementType.KEYBOARD
			3: movement_type = MovementType.JOYSTICK
			4: movement_type = MovementType.TOUCH
			5: movement_type = MovementType.AI
	if data.has("aim_type"):
		match int(data["aim_type"]):
			0: aim_type = AimType.DEFAULT
			1: aim_type = AimType.MOUSE
			2: aim_type = AimType.KEYBOARD
			3: aim_type = AimType.JOYSTICK
			4: aim_type = AimType.TOUCH
			5: aim_type = AimType.AI
	if data.has("facing_type"):
		match int(data["facing_type"]):
			0: facing_type = FacingType.DEFAULT
			1: facing_type = FacingType.MOUSE
			2: facing_type = FacingType.KEYBOARD
			3: facing_type = FacingType.JOYSTICK
			4: facing_type = FacingType.TOUCH
			5: facing_type = FacingType.AI
	if data.has("attack_type"):
		match int(data["attack_type"]):
			0: attack_type = AttackType.DEFAULT
			1: attack_type = AttackType.MOUSE
			2: attack_type = AttackType.KEYBOARD
			3: attack_type = AttackType.JOYSTICK
			4: attack_type = AttackType.TOUCH
			5: attack_type = AttackType.AI
	if data.has("custom_key_bindings"):
		custom_key_bindings = data["custom_key_bindings"]
	if data.has("zoom_level"):
		zoom_level = data["zoom_level"]

func init_restore():
	var data = FilesUtil.restore_or_create("user://user_config.json", save())
	if data != null:
		restore(data)
	loaded.emit(save())

func save_to_file():
	var save_data = save()
	FilesUtil.save("user://user_config.json", save_data)

func reset():
	master_volume = 50.0
	music_volume = 50.0
	ambience_volume = 50.0
	effects_volume = 50.0
	movement_type = MovementType.DEFAULT
	aim_type = AimType.DEFAULT
	facing_type = FacingType.DEFAULT
	attack_type = AttackType.DEFAULT
	custom_key_bindings.clear()
	zoom_level = 1.0
	save_to_file()

func reset_key_bindings():
	custom_key_bindings.clear()
	save_to_file()

func save_key_bindings(bindings: Dictionary):
	custom_key_bindings = bindings
	save_to_file()

func save_single_key_binding(action_name: String, events: Array):
	var event_data_list = []
	for event in events:
		event_data_list.append(_serialize_input_event(event))
	
	custom_key_bindings[action_name] = event_data_list
	save_to_file()

func load_key_bindings() -> Dictionary:
	return custom_key_bindings

func apply_key_bindings():
	if custom_key_bindings.is_empty():
		return
	
	for action_name in custom_key_bindings:
		var event_data_list = custom_key_bindings[action_name]
		
		# Check if the action exists in InputMap
		if not InputMap.has_action(action_name):
			continue
		
		# Clear existing events for this action
		InputMap.action_erase_events(action_name)
		
		# Add the saved events
		for event_data in event_data_list:
			var event = _deserialize_input_event(event_data)
			if event:
				InputMap.action_add_event(action_name, event)
	
func _serialize_input_event(event: InputEvent) -> Dictionary:
	var data = {}
	
	if event is InputEventKey:
		data["type"] = "key"
		data["keycode"] = event.keycode
		data["physical_keycode"] = event.physical_keycode
	elif event is InputEventMouseButton:
		data["type"] = "mouse_button"
		data["button_index"] = event.button_index
	elif event is InputEventJoypadButton:
		data["type"] = "joypad_button"
		data["button_index"] = event.button_index
	elif event is InputEventJoypadMotion:
		data["type"] = "joypad_motion"
		data["axis"] = event.axis
		data["axis_value"] = event.axis_value
	
	return data

func _deserialize_input_event(data: Dictionary) -> InputEvent:
	match data.get("type", ""):
		"key":
			var event = InputEventKey.new()
			event.keycode = data.get("keycode", 0)
			event.physical_keycode = data.get("physical_keycode", 0)
			return event
		"mouse_button":
			var event = InputEventMouseButton.new()
			event.button_index = data.get("button_index", 0)
			return event
		"joypad_button":
			var event = InputEventJoypadButton.new()
			event.button_index = data.get("button_index", 0)
			return event
		"joypad_motion":
			var event = InputEventJoypadMotion.new()
			event.axis = data.get("axis", 0)
			event.axis_value = data.get("axis_value", 0.0)
			return event
	
	return null

func print_config():
	print("UserConfig: ", save())
	print("AimType.DEFAULT: ", AimType.DEFAULT)
	print("AimType.MOUSE: ", AimType.MOUSE)
	print("AimType.KEYBOARD: ", AimType.KEYBOARD)
	print("AimType.JOYSTICK: ", AimType.JOYSTICK)
	print("AimType.TOUCH: ", AimType.TOUCH)
	print("AimType.AI: ", AimType.AI)
	print("MovementType.DEFAULT: ", MovementType.DEFAULT)
	print("MovementType.MOUSE: ", MovementType.MOUSE)
	print("MovementType.KEYBOARD: ", MovementType.KEYBOARD)
	print("MovementType.JOYSTICK: ", MovementType.JOYSTICK)
	print("MovementType.TOUCH: ", MovementType.TOUCH)
	print("MovementType.AI: ", MovementType.AI)
	print("FacingType.DEFAULT: ", FacingType.DEFAULT)
	print("FacingType.MOUSE: ", FacingType.MOUSE)
	print("FacingType.KEYBOARD: ", FacingType.KEYBOARD)
	print("FacingType.JOYSTICK: ", FacingType.JOYSTICK)
	print("FacingType.TOUCH: ", FacingType.TOUCH)
	print("FacingType.AI: ", FacingType.AI)
	print("AttackType.DEFAULT: ", AttackType.DEFAULT)
	print("AttackType.MOUSE: ", AttackType.MOUSE)
	print("AttackType.KEYBOARD: ", AttackType.KEYBOARD)
	print("AttackType.JOYSTICK: ", AttackType.JOYSTICK)
	print("AttackType.TOUCH: ", AttackType.TOUCH)
	print("AttackType.AI: ", AttackType.AI)
