class_name AnimationState extends State

@export var animation_name: String = ""
@export var play_on_enter: bool = true
@export var wait_for_animation_finished: bool = false
@export var use_animated_sprite: bool = true
@export var dispatch_state: String = ""
@export var freeze_physics: bool = false
@export var freeze_state: bool = false

var is_animation_finished: bool = false

func enter() -> void:
	super.enter()
	if play_on_enter:
		play_animation(wait_for_animation_finished)

func play_animation(wait_for_finished: bool = false):
	is_animation_finished = false
	if not use_animated_sprite and parent.animation_player and animation_name != "":
		parent.animation_player.play(animation_name)
		if wait_for_finished:
			await parent.animation_player.animation_finished
			is_animation_finished = true
			return
	if use_animated_sprite and parent.animated_sprite and animation_name != "":
		parent.animated_sprite.play(animation_name)
		if wait_for_finished:
			await parent.animated_sprite.animation_finished
			is_animation_finished = true
			return
	is_animation_finished = true
	
func play_animation_name(an: String, wait_for_finished: bool = false):
	is_animation_finished = false
	if not use_animated_sprite and parent.animation_player and an != "":
		parent.animation_player.play(an)
		if wait_for_finished:
			await parent.animation_player.animation_finished
			is_animation_finished = true
			return
	if use_animated_sprite and parent.animated_sprite and an != "":
		parent.animated_sprite.play(an)
		if wait_for_finished:
			await parent.animated_sprite.animation_finished
			is_animation_finished = true
			return
	is_animation_finished = true

func dispatch():
	if dispatch_state != "":
		state_machine.dispatch(dispatch_state)
