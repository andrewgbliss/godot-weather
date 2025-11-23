class_name Cutscene extends Node2D

@onready var camera : Camera2D = $Camera2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func start():
	focus()
	animation_player.play("transition_in")

func stop():
	animation_player.play("transition_out")

func focus():
	if camera:
		camera.enabled = true
		camera.make_current()
