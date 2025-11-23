class_name TopdownStateMachine extends StateMachine

@export var character: CharacterController

func _ready() -> void:
	init(character)
	add_transition(states["MoveState"], states["DashState"], "dash")
	add_transition(states["DashState"], states["MoveState"], "move")

func _unhandled_input(event: InputEvent) -> void:
	process_input(event)

func _physics_process(delta: float) -> void:
	process_physics(delta)

func _process(delta: float) -> void:
	process_frame(delta)
