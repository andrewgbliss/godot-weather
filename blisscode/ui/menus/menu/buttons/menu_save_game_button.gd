class_name MenuGameSaveButton extends Button
	
@export var description: LineEdit
@export var saved_games_list: SavedGamesList
@export var load_games_list: SavedGamesList

func _ready() -> void:
	pressed.connect(_on_button_pressed)
	description.text_changed.connect(_on_description_text_changed)
	disabled = true
	
func _on_button_pressed() -> void:
	UserDataStore.save(description.text.trim_prefix(" ").trim_suffix(" "))
	description.text = ""
	saved_games_list.refresh()
	load_games_list.refresh()

func _on_description_text_changed(new_text: String) -> void:
	if new_text == "":
		disabled = true
	else:
		disabled = false
