extends Node

@export var max_rewind_time: float = 3.0
@export var rewind_input_action: String = "rewind"

var state_history: Array = []
var max_history_size: int
var store_timer: float = 0.0
var store_interval: float = 0.5

var is_rewinding: bool = false
var rewind_timer: float = 0.0
var rewind_interval: float = 0.1 # How often to restore while rewinding

func _ready():
	max_history_size = int(max_rewind_time / store_interval)
		
func _physics_process(delta):
	# Store state every second when not rewinding
	if not is_rewinding:
		store_timer += delta
		if store_timer >= store_interval:
			_store_current_state()
			store_timer = 0.0
	
	# Handle continuous rewind
	elif is_rewinding:
		rewind_timer += delta
		if rewind_timer >= rewind_interval:
			_restore_next_state()
			rewind_timer = 0.0

func _input(event):
	if event.is_action_pressed(rewind_input_action):
		_start_rewind()
	elif event.is_action_released(rewind_input_action):
		_stop_rewind()

func _store_current_state():
	var persisting_nodes_data = UserDataStore.get_persisting_nodes()
	
	if persisting_nodes_data.size() > 0:
		var state_snapshot = {
			"timestamp": Time.get_ticks_msec(),
			"nodes_data": persisting_nodes_data
		}
		state_history.append(state_snapshot)
		
		if state_history.size() > max_history_size:
			state_history.pop_front()

func _start_rewind():
	if state_history.is_empty():
		return
	
	is_rewinding = true
	rewind_timer = 0.0

func _restore_next_state():
	if state_history.is_empty():
		_stop_rewind()
		return
	
	# Get the most recent state and restore it
	var state_snapshot = state_history.pop_back()
	var nodes_data = state_snapshot.get("nodes_data", [])
	
	UserDataStore.restore_all_nodes(nodes_data)

func _stop_rewind():
	is_rewinding = false

func start_rewind():
	_start_rewind()

func stop_rewind():
	_stop_rewind()

func clear_history():
	state_history.clear()

func get_history_size() -> int:
	return state_history.size()

func is_rewind_available() -> bool:
	return not state_history.is_empty()
