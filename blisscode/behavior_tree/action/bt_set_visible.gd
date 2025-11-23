class_name BTSetVisible extends BTNode

@export var visible: bool = true
@export var node: CanvasItem

func process(_delta: float) -> Status:
	node.visible = visible
	return Status.SUCCESS
