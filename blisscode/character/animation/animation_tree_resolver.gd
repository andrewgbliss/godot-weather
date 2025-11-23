class_name AnimationTreeResolver extends Node

@export var agent: CharacterController
@export var animation_tree: AnimationTree

func _process(_delta: float) -> void:
	_update_animation_tree()

func _update_animation_tree():
	if animation_tree and agent.controls:
		var looking_at = agent.controls.get_aim_direction()
		animation_tree.set("parameters/PlayerStates/Idle/blend_position", looking_at)
		animation_tree.set("parameters/PlayerStates/Walk/blend_position", looking_at)
		animation_tree.set("parameters/PlayerStates/Jump/blend_position", looking_at)
		animation_tree.set("parameters/TimeScale/scale", agent.time_scale)
