class_name MenuGameStartButton extends Button

@export var user_folder_index: int

func _ready() -> void:
	pressed.connect(_on_button_pressed)
	
func _on_button_pressed() -> void:
	UserDataStore.user_data_store_config.user_folder_index = user_folder_index
	GameManager.game_start()
