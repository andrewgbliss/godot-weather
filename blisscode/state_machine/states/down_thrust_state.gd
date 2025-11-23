class_name DownThrustState extends MoveState

@export var hitbox: Hitbox

func enter() -> void:
	super.enter()
	if hitbox:
		hitbox.get_node("CollisionShape2D").disabled = false

func process_physics(delta: float) -> void:
	var direction = parent.controls.get_movement_direction()
	parent.move(direction, delta)
	if not parent.controls.is_pressing_down():
		state_machine.dispatch("idle")
		return

func exit() -> void:
	super.exit()
	if hitbox:
		hitbox.get_node("CollisionShape2D").disabled = true
