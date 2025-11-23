class_name BTPlayAnimation extends BTNode

@export var animation_player : AnimationPlayer
@export var animation_name: String = ""

func enter():
	if animation_player and animation_name != "":
		animation_player.play(animation_name)
		return
	if agent.animation_player and animation_name != "":
		agent.animation_player.play(animation_name)

func process(_delta: float) -> Status:	
	return Status.SUCCESS
