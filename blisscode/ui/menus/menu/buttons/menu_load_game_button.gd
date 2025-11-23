class_name MenuLoadGameButton extends Button

@export var restore_index: int = -1

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if restore_index >= 0:
		UserDataStore.user_data_store_config.restore_index = restore_index
		GameManager.game_restore()
	else:
		print("Invalid save index: ", restore_index)
