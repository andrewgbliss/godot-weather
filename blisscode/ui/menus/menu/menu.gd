class_name Menu extends CanvasLayer

@export var menu_name: String = ""
@export var animation_transition_in: String = "transition_in"
@export var animation_transition_out: String = "transition_out"
@export var animation_transition_away_in: String = "transition_away_in"
@export var animation_transition_away_out: String = "transition_away_out"
@export var input_action: String = ""

@export var required_game_state: GameConfig.GAME_STATE = GameConfig.GAME_STATE.GAME_PLAY
@export var pause_game: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _input(event: InputEvent) -> void:
	if input_action != "":
		if GameManager.game_config.game_state == required_game_state:
			if event.is_action_pressed(input_action):
				if not get_tree().paused:
						if pause_game:
							GameManager.pause()
						GameUi.game_menus.menu_stack.push(menu_name)
				else:
					if GameUi.game_menus.menu_stack.size() > 0 and GameUi.game_menus.menu_stack.get_top() != menu_name:
						await GameUi.game_menus.menu_stack.pop()
						GameUi.game_menus.menu_stack.push(menu_name)
					else:
						if pause_game:
							GameManager.unpause()
						GameUi.game_menus.menu_stack.pop_all()

func _ready():
	_off()

func _off():
	hide()
	set_process(false)

func _on():
	show()
	set_process(true)

func transition_in():
	_on()
	animation_player.play(animation_transition_in)
	await animation_player.animation_finished

func transition_out():
	animation_player.play(animation_transition_out)
	await animation_player.animation_finished
	_off()

func transition_away_in():
	_on()
	animation_player.play(animation_transition_away_in)
	await animation_player.animation_finished
	
func transition_away_out():
	animation_player.play(animation_transition_away_out)
	await animation_player.animation_finished
	_off()
