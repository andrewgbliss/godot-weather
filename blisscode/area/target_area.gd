class_name TargetArea extends Area2D

@export var group: StringName
@export var target_var: StringName = &"target"
@export var blackboard: BTBlackboard

func _ready() -> void:
	body_entered.connect(Callable(_on_body_entered))
	body_exited.connect(Callable(_on_body_exited))

func _on_body_entered(body) -> void:
	if body.is_in_group(group):
		blackboard.set_var(target_var, body)

func _on_body_exited(body) -> void:
	if body.is_in_group(group):
		blackboard.set_var(target_var, null)
