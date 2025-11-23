class_name BTShowSprite extends BTNode

@export var show: bool = true

func process(_delta: float) -> Status:
	agent.sprite.visible = show
	return Status.SUCCESS
