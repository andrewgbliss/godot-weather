extends Label

@export var controls: CharacterControls
@export var state_machine: StateMachine

var parent

var parent_position = Vector2.ZERO
var current_gold = 0
var current_state: State = null

func _ready() -> void:
	parent = get_parent()
	if parent.character.inventory:
		parent.character.inventory.gold_changed.connect(_on_gold_changed)
		current_gold = parent.character.inventory.gold
	if state_machine:
		state_machine.active_state_changed.connect(_on_active_state_changed)
		current_state = state_machine.current_state

func _process(_delta: float) -> void:
	_update_label()

func _update_label():
	var movement_direction = controls.get_movement_direction()
	parent_position = parent.global_position.round()
	var state_name = ""
	if current_state:
		state_name = current_state.name
	else:
		state_name = "None"

	var physics_group_name = ""
	if parent.character.get_physics_group():
		physics_group_name = parent.character.get_physics_group().name
	else:
		physics_group_name = "None"

	text = "%s\n%s\n%s\n%s\n%s" % [parent_position, movement_direction.normalized(), current_gold, state_name, physics_group_name]
	
func _on_gold_changed(amount):
	current_gold = amount

func _on_active_state_changed(new_state: State, _old_state: State):
	current_state = new_state
