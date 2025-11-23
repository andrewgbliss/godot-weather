class_name Jukebox extends Node2D

@export var play_on_start: bool = false
@export var fade_duration: float = 5.0
@export var data_store_dir: String = "playlists"

@export_group("UI")
@export var playlist_name_label: Label
@export var song_name_label: Label
@export var previous_button: TextureButton
@export var play_button: TextureButton
@export var stop_button: TextureButton
@export var pause_button: TextureButton
@export var repeat_button: TextureButton
@export var next_button: TextureButton
@export var songlist_container: VBoxContainer
@export var track_progress: HSlider
@export var time_label: Label
@export var song_container_scene: PackedScene
@export var scroll_container: ScrollContainer
@export var player_controls: HBoxContainer
@export var load_folder_button: Button
@export var load_album_button: Button
@export var load_folder_text_edit: TextEdit
@export var folder_tree: Tree
@export var minimize_button: TextureButton
@export var close_button: TextureButton

var is_playing: bool = false
var is_repeating: bool = false
var current_track_index: int = -1
var current_track_name: String = ""
var preloaded_tracks: Array = []
var fade_tween: Tween
var current_song_container: SongContainer = null
var is_seeking: bool = false
var current_playlist: String = ""

func _ready():
	call_deferred("_after_ready")

func _after_ready():
	previous_button.pressed.connect(_on_previous_button_pressed)
	play_button.pressed.connect(_on_play_button_pressed)
	stop_button.pressed.connect(_on_stop_button_pressed)
	pause_button.pressed.connect(_on_pause_button_pressed)
	repeat_button.pressed.connect(_on_repeat_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	track_progress.value_changed.connect(_on_track_progress_changed)
	load_folder_button.pressed.connect(_on_load_folder_button_pressed)
	load_album_button.pressed.connect(_on_album_selected)
	folder_tree.item_activated.connect(_on_album_selected)
	minimize_button.pressed.connect(_on_minimize_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)

	stop_button.hide()
	pause_button.hide()

	play_button.show()
	play_button.grab_focus()

func _process(_delta: float) -> void:
	if current_song_container and current_song_container.is_playing:
		_update_time_label()

func _on_minimize_button_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED);
	
func _on_close_button_pressed() -> void:
	get_tree().quit()

func _on_load_folder_button_pressed() -> void:
	folder_tree.clear()
	var folder_path = load_folder_text_edit.text
	if folder_path:
		var dir = DirAccess.open(folder_path)
		var dirs = dir.get_directories()
		var root = folder_tree.create_item()
		root.set_text(0, "Albums")
		for d in dirs:
			var child = folder_tree.create_item(root)
			child.set_text(0, d)
			
	
func _on_album_selected() -> void:
	current_track_index = -1
	preloaded_tracks = []
	for c in songlist_container.get_children():
		c.queue_free()
	var selected_item = folder_tree.get_selected()
	var full_path = load_folder_text_edit.text + "/" + selected_item.get_text(0)
	preload_mp3_folder_tracks(full_path, "mp3")
	_build_playlist()
	pause_button.hide()
	stop_button.hide()
	play_button.show()
	play_button.grab_focus()

func _on_player_controls_focus_entered() -> void:
	if current_song_container and current_song_container.is_playing:
		pause_button.grab_focus()
	else:
		play_button.grab_focus()

func preload_mp3_folder_tracks(path: String, ext: String):
	preloaded_tracks = []
	var dir = DirAccess.open(path)
	var files = dir.get_files()
	for file in files:
		if file.ends_with(ext):
			var track_name = file
			var track_object = {
				"name": track_name,
				"track": AudioUtils.load_mp3(path + "/" + file)
			}
			preloaded_tracks.append(track_object)
		else:
			print("Failed to load track: ", path + "/" + file)

func get_current_track_name() -> String:
	var track_objects: Array = preloaded_tracks
	if track_objects.size() > current_track_index:
		return track_objects[current_track_index].name
	return ""

func get_playlist_track_names() -> Array:
	var track_objects: Array = preloaded_tracks
	if track_objects != []:
		return track_objects.map(func(track_object): return track_object.name)
	return []

func _on_previous_button_pressed() -> void:
	if current_track_index == 0:
		current_track_index = preloaded_tracks.size() - 1
	else:
		current_track_index -= 1
	current_song_container = songlist_container.get_child(current_track_index)
	_play_current_song()
	pause_button.grab_focus()

func _on_next_button_pressed() -> void:
	_next_song(current_track_index)
	_play_current_song()
	pause_button.grab_focus()

func _next_song(index: int = -1) -> void:
	current_track_index = (index + 1) % preloaded_tracks.size()
	current_song_container = songlist_container.get_child(current_track_index)

func _stop_all_songs() -> void:
	for child in songlist_container.get_children():
		child.stop()

func _stop_other_songs() -> void:
	for child in songlist_container.get_children():
		if child != current_song_container:
			child.stop()

func _play_current_song() -> void:
	time_label.text = _get_song_length()
	if not current_song_container.is_playing:
		current_song_container.play()
	pause_button.show()
	stop_button.show()
	play_button.hide()
	pause_button.grab_focus()
	_stop_other_songs()
	song_name_label.text = current_song_container.track_name.text
	scroll_container.ensure_control_visible(current_song_container)

func _get_song_length() -> String:
	var seconds = current_song_container.audio_stream_player.stream.get_length()
	var minutes = seconds / 60
	var hours = minutes / 60
	return str(hours) + ":" + str(minutes) + ":" + str(seconds)

func _get_current_position() -> String:
	var total_seconds = int(current_song_container.audio_stream_player.get_playback_position())
	@warning_ignore("integer_division")
	var minutes = int(total_seconds / 60)
	var seconds = total_seconds % 60
	return str(minutes) + ":" + str(seconds).pad_zeros(2)

func _update_time_label() -> void:
	time_label.text = _get_current_position()
	if not is_seeking:
		var current_position = current_song_container.audio_stream_player.get_playback_position()
		var song_length = current_song_container.audio_stream_player.stream.get_length()
		track_progress.set_value_no_signal(current_position / song_length)

func _on_play_button_pressed() -> void:
	play_button.hide()
	pause_button.show()
	stop_button.show()
	if current_song_container == null:
		_next_song(-1)

	_play_current_song()
	track_progress.focus_neighbor_bottom = pause_button.get_path()
	
func _on_pause_button_pressed() -> void:
	pause_button.hide()
	play_button.show()
	stop_button.hide()
	play_button.grab_focus()
	current_song_container.pause()
	track_progress.focus_neighbor_bottom = play_button.get_path()

func _on_stop_button_pressed() -> void:
	play_button.show()
	pause_button.hide()
	stop_button.hide()
	play_button.grab_focus()
	_stop_all_songs()
	track_progress.focus_neighbor_bottom = play_button.get_path()
	

func _on_song_play_button_pressed(container: SongContainer) -> void:
	current_song_container = container
	_play_current_song()
	
func _on_song_stop_button_pressed(_container: SongContainer) -> void:
	pause_button.hide()
	play_button.show()
	_stop_all_songs()

func _on_song_pause_button_pressed(_container: SongContainer) -> void:
	pause_button.hide()
	play_button.show()

func _on_repeat_button_pressed() -> void:
	is_repeating = !is_repeating
	if is_repeating:
		repeat_button.modulate = Color.YELLOW
	else:
		repeat_button.modulate = Color.WHITE
	if current_song_container and current_song_container.is_playing:
		pause_button.grab_focus()
	else:
		play_button.grab_focus()
#
func _build_playlist() -> void:
	playlist_name_label.text = ""
	song_name_label.text = ""
	for track in preloaded_tracks:
		var song_container = song_container_scene.instantiate()
		for pr_track in preloaded_tracks:
			if pr_track.name == track.name:
				var stream = pr_track.track
				song_container.set_stream(stream)
				break
		song_container.track_name.text = track.name
		song_container.play_button_pressed.connect(_on_song_play_button_pressed)
		song_container.pause_button_pressed.connect(_on_song_pause_button_pressed)
		song_container.stop_button_pressed.connect(_on_song_stop_button_pressed)
		song_container.song_finished.connect(_on_song_finished)
		song_container.double_click_song_pressed.connect(_on_song_double_click_pressed)
		songlist_container.add_child(song_container)

func _on_song_finished(_container: SongContainer) -> void:
	if is_repeating:
		_stop_all_songs()
		_play_current_song()
	else:
		_next_song(current_track_index)
		_play_current_song()

func _on_track_progress_changed(value: float) -> void:
	if not current_song_container:
		return
	var total_seconds = current_song_container.audio_stream_player.stream.get_length()
	var seek_seconds = value * total_seconds
	current_song_container.audio_stream_player.seek(seek_seconds)

func _on_song_double_click_pressed(container: SongContainer) -> void:
	for i in range(songlist_container.get_child_count()):
		if songlist_container.get_child(i) == container:
			current_track_index = i
			current_song_container = songlist_container.get_child(current_track_index)
			_play_current_song()
			break
