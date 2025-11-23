class_name SavedGamesList extends VBoxContainer

func _ready() -> void:
	load_saved_games()

func load_saved_games() -> void:
	# Clear existing children
	for child in get_children():
		child.queue_free()
	
	var saved_games = UserDataStore.get_saves()
	
	# Sort saves by timestamp (newest first)
	saved_games.sort_custom(func(a, b): return a.get("timestamp", "") > b.get("timestamp", ""))
	
	# Create HBox for each saved game
	for save_data in saved_games:
		create_save_game_row(save_data)

# Create a single row (HBox) for a save game
func create_save_game_row(save_data: Dictionary) -> void:
	var hbox = HBoxContainer.new()
	add_child(hbox)
	
	# Description label (expands to fill available space)
	var description_label = Label.new()
	description_label.text = save_data.get("description", "Unnamed Save")
	description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(description_label)
	
	# Date label (fixed size)
	var date_label = Label.new()
	date_label.text = format_timestamp(save_data.get("timestamp", "Unknown Date"))
	hbox.add_child(date_label)
	
	# Load button
	var load_button = MenuLoadGameButton.new()
	load_button.text = "Load"
	load_button.restore_index = save_data.get("index", -1)
	hbox.add_child(load_button)

# Format timestamp to be more user-friendly
func format_timestamp(timestamp: String) -> String:
	if timestamp == "Unknown Date":
		return timestamp
	
	# Parse the timestamp string (format: "YYYY-MM-DD HH:MM:SS")
	var parts = timestamp.split(" ")
	if parts.size() < 2:
		return timestamp
	
	var date_parts = parts[0].split("-")
	var time_parts = parts[1].split(":")
	
	if date_parts.size() < 3 or time_parts.size() < 3:
		return timestamp
	
	# Format as "MM/DD/YYYY HH:MM"
	var month = date_parts[1]
	var day = date_parts[2]
	var year = date_parts[0]
	var hour = time_parts[0]
	var minute = time_parts[1]
	
	return "%s/%s/%s %s:%s" % [month, day, year, hour, minute]

# Public method to refresh the list
func refresh() -> void:
	load_saved_games()
