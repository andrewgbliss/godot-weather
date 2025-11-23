class_name UserDataStoreConfig extends Resource

@export var players: int = 4
@export var user_folder_index: int = 0
@export var save_index: int = 0
@export var restore_index: int = 0

func save():
	return {
		"players": players,
		"user_folder_index": user_folder_index,
		"save_index": save_index,
		"restore_index": restore_index
	}

func restore(data):
	if data.has("players"):
		players = data["players"]
	if data.has("user_folder_index"):
		user_folder_index = data["user_folder_index"]
	if data.has("save_index"):
		save_index = data["save_index"]
	if data.has("restore_index"):
		restore_index = data["restore_index"]

func init_restore():
	var data = FilesUtil.restore_or_create("user://user_data_store_config.json", save())
	if data != null:
		restore(data)

func save_to_file():
	FilesUtil.save("user://user_data_store_config.json", save())

func reset():
	players = 4
	user_folder_index = 0
	save_index = 0
	restore_index = 0
	save_to_file()
