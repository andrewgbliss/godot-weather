class_name PhysicsArea2D extends Area2D

@export var physics_group_override: PhysicsGroup
@export var dispatch_enter_state: StringName
@export var dispatch_exit_state: StringName

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterController:
		body.character.set_physics_group_override(physics_group_override)
		if dispatch_enter_state:
			body.state_machine.dispatch(dispatch_enter_state, true)

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterController:
		body.character.reset_physics_group_override()
		if dispatch_exit_state:
			body.state_machine.dispatch(dispatch_exit_state, true)
