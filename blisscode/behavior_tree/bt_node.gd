class_name BTNode extends Node

enum Status {RUNNING, SUCCESS, FAILURE}

var blackboard: BTBlackboard
var agent

func enter():
	pass # Called when the node starts execution

func process(_delta: float) -> Status:
	return Status.FAILURE # Each node overrides this

func exit():
	pass # Called when the node stops execution
