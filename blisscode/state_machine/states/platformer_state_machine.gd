class_name PlatformerStateMachine extends StateMachine

@export var character: CharacterController

func _ready() -> void:
	init(character)

	add_transition(null, states["SpawnState"], "spawn")

	add_transition(null, states["IdleState"], "idle")
	add_transition(null, states["WalkState"], "walk")
	add_transition(null, states["RunState"], "run")

	add_transition(null, states["CrouchIdleState"], "crouch_idle")
	add_transition(null, states["CrouchWalkState"], "crouch_walk")

	add_transition(null, states["DashState"], "dash")
	add_transition(states["DashState"], states["IdleState"], "dash_stop")

	add_transition(null, states["JumpState"], "jump")
	add_transition(states["RunState"], states["JumpFlipState"], "jump_flip")
	add_transition(null, states["FallingState"], "falling")
	add_transition(null, states["LandState"], "land")

	add_transition(null, states["RollState"], "roll")

	add_transition(states["JumpState"], states["WallClingState"], "wall_cling")
	add_transition(states["WallClingState"], states["WallJumpState"], "wall_jump")

	add_transition(null, states["AttackState"], "attack")
	add_transition(states["AttackState"], null, "attack_finished")

	add_transition(states["JumpState"], states["UpThrustState"], "up_thrust")
	add_transition(states["JumpState"], states["DownThrustState"], "down_thrust")

	add_transition(null, states["SlideState"], "slide")
	add_transition(states["SlideState"], states["IdleState"], "slide_stop")

	add_transition(null, states["PushState"], "push")
	add_transition(states["PushState"], states["PushIdleState"], "push_idle")

	add_transition(states["IdleState"], states["DanglingState"], "dangling")

	add_transition(states["LadderClimbState"], states["LadderIdleState"], "ladder_idle")
	add_transition(null, states["LadderClimbState"], "ladder_climb")

	add_transition(null, states["SwimState"], "swim")

	add_transition(null, states["LedgeGrabState"], "ledge_grab")
	add_transition(states["LedgeGrabState"], states["LedgeClimbState"], "ledge_climb")

	add_transition(null, states["SmashDownState"], "smash_down")

	add_transition(null, states["DamageState"], "damage")
	add_transition(null, states["DeathState"], "death")

	call_deferred("_after_ready")

func _after_ready() -> void:
	start()

func _unhandled_input(event: InputEvent) -> void:
	process_input(event)

func _physics_process(delta: float) -> void:
	process_physics(delta)

func _process(delta: float) -> void:
	process_frame(delta)
