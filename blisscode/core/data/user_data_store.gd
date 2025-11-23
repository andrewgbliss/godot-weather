@tool
extends Node

var base_dir = "user://user_data_store"
@export var user_data_store_config: UserDataStoreConfig

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
func get_player_dir() -> String:
	return str(base_dir, "/", user_data_store_config.user_folder_index)

func get_saves():
	var saves = []
	var player_dir = get_player_dir()
	if DirAccess.dir_exists_absolute(player_dir):
		for file in DirAccess.get_files_at(player_dir):
			if file.begins_with("user_data_store_"):
				var index = file.get_file().get_basename().get_slice("_", 3)
				var path = str(player_dir, "/user_data_store_", index, ".dat")
				var data = FilesUtil.restore(path)
				if data:
					saves.append(data)
	return saves

func get_restore_data():
	var player_dir = get_player_dir()
	var index = user_data_store_config.restore_index
	var path = str(player_dir, "/user_data_store_", index, ".dat")
	var data = FilesUtil.restore(path)
	return data

func _get_next_index():
	var index = 0
	var player_dir = get_player_dir()
	if DirAccess.dir_exists_absolute(player_dir):
		for file in DirAccess.get_files_at(player_dir):
			if file.begins_with("user_data_store_"):
				var index_str = file.get_file().get_basename().get_slice("_", 3)
				if index_str.is_valid_int():
					index = max(index, index_str.to_int())
	return index + 1

func save(description: String):
	var player_dir = get_player_dir()
	FilesUtil.create_dir(player_dir) # Ensure directory exists
	var index = _get_next_index()
	var path = str(player_dir, "/user_data_store_", index, ".dat")
	var world_data = _get_world_data()
	var data = {
		"index": index,
		"description": description,
		"timestamp": Time.get_datetime_string_from_system(false, true),
		"world_data": world_data
	}
	FilesUtil.save(path, data)
	save_persisting_nodes(index)
	
func restore():
	print("Restoring persisting nodes")
	_restore_persisting_nodes()
	
func _get_world_data():
	var root = get_tree().get_root()
	for node in root.get_children():
		if node is World:
			return node.save()
	return null

func save_persisting_nodes(index):
	if not get_tree():
		return
	var player_dir = get_player_dir()
	var path = str(player_dir, "/persist_nodes_", index, ".dat")
	var file = FileAccess.open(path, FileAccess.WRITE)
	var save_nodes = get_persisting_nodes()
	for node_data in save_nodes:
#		# Store the save dictionary as a new line in the save file.
		file.store_line(JSON.stringify(node_data))
		file.close()

func get_persisting_nodes():
	var save_nodes = get_tree().get_nodes_in_group("persist")
	var node_data_arr = []
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		# Call the node's save function.
		var node_data = node.call("save")
		node_data_arr.append(node_data)
	return node_data_arr

func _restore_persisting_nodes():
	var index = user_data_store_config.restore_index
	var player_dir = get_player_dir()
	var path = str(player_dir, "/persist_nodes_", index, ".dat")
	if not FileAccess.file_exists(path):
		return
	var file = FileAccess.open(path, FileAccess.READ)
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	while file.get_position() < file.get_length():
		var json = JSON.new()
		var line = file.get_line()
		# Get the saved dictionary from the next line in the save file
		var error = json.parse(line)
		if error == OK:
			var node_data = json.get_data()
			var node = get_node(node_data.get("path"))
			if node != null:
				var new_position = Vector2(node_data.get("pos_x"), node_data.get("pos_y"))
				node.position = new_position
				# Now we set the remaining variables.
				for i in node_data.keys():
					if i == "filename" or i == "parent" or i == "path" or i == "pos_x" or i == "pos_y" or i == "input_x" or i == "input_y" or i == "movement_direction" or i == "movement_state" or i == "is_facing_right":
						continue
					node.set(i, node_data.get(i))
					
				if node.has_method("restore"):
					node.call("restore", node_data)

				if node.has_method("spawn_restore"):
					node.call("spawn_restore")
#
			# print(node, node_data)
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", line, " at line ", json.get_error_line())
	file.close()

func restore_all_nodes(nodes_data: Array):
	for node_data in nodes_data:
		var node_path = node_data.get("path")
		if node_path:
			var node = get_node_or_null(node_path)
			if node != null:
				# Call custom restore method if available
				if node.has_method("restore"):
					node.call("restore", node_data)
			else:
				print("Warning: Could not find node at path: ", node_path)

func reset():
	FilesUtil.remove_dir(base_dir)
