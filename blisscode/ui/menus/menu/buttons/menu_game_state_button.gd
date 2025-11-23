class_name MenuGameStateButton extends Button

@export var game_state : GameConfig.GAME_STATE

func _ready() -> void:
	pressed.connect(_on_button_pressed)
	
func _on_button_pressed() -> void:
	GameManager.game_config.set_state(game_state)
	
