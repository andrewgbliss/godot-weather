class_name CharacterControls extends Node

var touch_position: Vector2 = Vector2.ZERO
var is_touching: bool = false

enum DOUBLE_TAP_DIRECTION {NONE, LEFT, RIGHT, UP, DOWN}

var double_tap_direction = DOUBLE_TAP_DIRECTION.NONE
var double_tap_timer: Timer = null
var double_tap_time: float = 0.3
var double_tap_count: int = 0
var last_pressed_movement: String = ""

var parent: CharacterController

func _ready() -> void:
	parent = get_parent()

func get_movement_direction() -> Vector2:
	return Vector2.ZERO

func get_aim_direction() -> Vector2:
	return Vector2.ZERO

func get_facing_direction():
	return Vector2.RIGHT if parent.is_facing_right else Vector2.LEFT

func get_double_tap_direction() -> Vector2:
	return Vector2.ZERO

func is_walking() -> bool:
	return false

func is_running() -> bool:
	return false

func is_action_just_pressed(_action_name) -> bool:
	return false

func is_action_pressed(_action_name) -> bool:
	return false

func is_pressing_right() -> bool:
	return false

func is_pressing_left() -> bool:
	return false

func is_pressing_up() -> bool:
	return false

func is_pressing_down() -> bool:
	return false