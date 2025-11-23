class_name PhysicsGroup extends Resource

@export var name: String = "Default"

@export var acceleration: float = 50.0
@export var friction: float = 70.0
@export var speed: float = 100.0
@export var max_velocity: Vector2 = Vector2(1000.0, 1000.0)
@export var gravity_percent: float = 1.0
@export var movement_percent: float = 1.0
@export var movement_lerp: bool = true
@export var has_navigation: bool = false
@export var allow_y_controls: bool = false

@export_group("Multipliers")
@export var walk_multiplier: float = 1.0
@export var run_multiplier: float = 3.0
@export var crouch_multiplier: float = 0.5

@export_group("Jump")
@export var jump_force: float = 100.0

@export_group("Roll")
@export var roll_speed_multiplier: float = 5.0

@export_group("Push")
@export var push_force: float = 300.0

@export_group("Knockback")
@export var knockback_force: float = 200.0
@export var knockback_resistance: float = 0.5

@export_group("Dash")
@export var dash_time: float = 0.5
@export var dash_speed_multiplier: float = 10.0
@export var stop_on_end: bool = false

@export_group("Slide")
@export var slide_time: float = 0.5
@export var slide_speed_multiplier: float = 10.0
@export var slide_stop_on_end: bool = false

@export_group("Wall Cling")
@export var require_input_direction: bool = false
@export var wall_cling_gravity_percent: float = 0.5

@export_group("Attack")
@export var attack_momentum_multiplier: float = 5.0
