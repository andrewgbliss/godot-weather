class_name StateMachine extends Node

@export var initial_state: State
@export var idle_state: State

var current_state: State
var states: Dictionary = {}
var transitions: Dictionary = {}
var shared_data: Dictionary = {}

signal active_state_changed

func init(parent) -> void:
	for child in get_children():
		child.parent = parent
		child.state_machine = self
		states[child.name] = child

func start() -> void:
	if initial_state:
		change_state(initial_state)
		
func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	if current_state:
		current_state.exit()
	active_state_changed.emit(new_state, current_state)
	current_state = new_state
	current_state.enter()
	
func process_input(event: InputEvent) -> void:
	current_state.process_input(event)

func process_frame(delta: float) -> void:
	current_state.process_frame(delta)

func process_physics(delta: float) -> void:
	current_state.process_physics(delta)
		
func dispatch(transition_name: String, force: bool = false):
	if not transitions.has(transition_name):
		return
	var s = transitions[transition_name]
	var state_a = s[0]
	var state_b = s[1]
	if current_state.freeze_state and not force:
		return
	if state_a == null:
		state_a = current_state
	if state_a and state_a.enabled:
		state_a.exit()
	if not state_b:
		state_b = idle_state
	if state_b and state_b.enabled:
		active_state_changed.emit(state_b, state_a)
		current_state = state_b
		current_state.enter()

	
func add_transition(state_a: State, state_b: State, transition_name: String):
	if transitions.has(transition_name):
		return
	transitions[transition_name] = [state_a, state_b]
	
func get_active_state():
	return current_state
