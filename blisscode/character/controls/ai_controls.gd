class_name AIControls extends CharacterControls

@export var blackboard: BTBlackboard
@export var target_var := &"target"
@export var movement_direction_var := &"movement_direction"
@export var left_hand_var := &"left_hand"
@export var right_hand_var := &"right_hand"
@export var is_walking_var := &"is_walking"
@export var is_running_var := &"is_running"

var run: bool = false

func get_movement_direction() -> Vector2:
	var direction: Vector2 = blackboard.get_var(movement_direction_var, Vector2.ZERO)
	return direction

func get_aim_direction() -> Vector2:
	var target: CharacterBody2D = blackboard.get_var(target_var, null)
	if target != null:
		return (target.global_position - parent.global_position).normalized()
	return Vector2.ZERO

func get_double_tap_direction() -> Vector2:
	return Vector2.ZERO

func is_walking() -> bool:
	var val = blackboard.get_var(is_walking_var, false)
	if val:
		return true
	var direction = get_movement_direction()
	return direction != Vector2.ZERO

func is_running() -> bool:
	var val = blackboard.get_var(is_running_var, false)
	if val:
		return true
	var direction = get_movement_direction()
	return direction != Vector2.ZERO and run

func is_action_just_pressed(_action_name) -> bool:
	return false

func is_action_pressed(_action_name) -> bool:
	return false

func is_attacking_left_hand():
	var left = blackboard.get_var(left_hand_var, false)
	return left

func is_attacking_right_hand():
	var right = blackboard.get_var(right_hand_var, false)
	return right
