class_name SpriteFacingDirection extends Node2D

@export var agent: CharacterController
@export var sprite: Sprite2D

func _process(_delta: float) -> void:
	_update_facing_direction()

func _update_facing_direction():
	if not agent.flip_h_lock:
		match GameManager.user_config.facing_type:
			UserConfig.FacingType.MOUSE:
				var mouse_pos = get_global_mouse_position()
				agent.is_facing_right = mouse_pos.x > agent.position.x
			UserConfig.FacingType.TOUCH:
				agent.is_facing_right = agent.controls.touch_position.x > agent.global_position.x
			UserConfig.FacingType.KEYBOARD:
				agent.is_facing_right = agent.velocity.x > 0
			UserConfig.FacingType.JOYSTICK:
				agent.is_facing_right = agent.controls.get_aim_direction().x > 0
			UserConfig.FacingType.DEFAULT:
				agent.is_facing_right = agent.velocity.x > 0
	_handle_flip()

func _handle_flip():
	sprite.flip_h = not agent.is_facing_right