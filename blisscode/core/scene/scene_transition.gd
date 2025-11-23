class_name SceneTransition extends CanvasLayer

@export var animation_transition_in: String = "transition_in"
@export var animation_transition_out: String = "transition_out"
@export var animation_blink: String = "blink"
@export var audio_click: AudioStreamPlayer
@export var next_transition: SceneTransition

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var bypass_blink: bool = false
var is_blinking: bool = false

func play():
	await transition_in()
	if animation_blink != "":
		if not bypass_blink:
			await blink()
	else:
		await transition_out()

func transition_in():
	animation_player.play(animation_transition_in)
	await animation_player.animation_finished

func blink():
	is_blinking = true
	animation_player.play(animation_blink)
	await animation_player.animation_finished
	is_blinking = false

func transition_out():
	animation_player.play(animation_transition_out)
	await animation_player.animation_finished

func next():
	audio_click.play()
	bypass_blink = true
	is_blinking = false
	animation_player.stop()
	await transition_out()
	return next_transition
