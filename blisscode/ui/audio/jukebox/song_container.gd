class_name SongContainer extends HBoxContainer

@export var path: String
@export var track_name: Label
@export var audio_stream_player: AudioStreamPlayer

signal play_button_pressed(container: SongContainer)
signal pause_button_pressed(container: SongContainer)
signal stop_button_pressed(container: SongContainer)
signal song_finished(container: SongContainer)
signal double_click_song_pressed(container: SongContainer)

var is_playing: bool = false

func _ready() -> void:
	audio_stream_player.finished.connect(_on_song_finished)
	if path:
		load_stream_player(path)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			double_click_song_pressed.emit(self)

func load_stream_player(p: String) -> void:
	var stream = AudioUtils.load_mp3(p)
	audio_stream_player.stream = stream

func set_stream(stream: AudioStream) -> void:
	audio_stream_player.stream = stream
	
func play():
	is_playing = true
	modulate = Color.YELLOW
	if audio_stream_player.stream_paused:
		audio_stream_player.stream_paused = false
		return
	audio_stream_player.play()

func pause():
	audio_stream_player.stream_paused = true
	is_playing = false
	modulate = Color.YELLOW

func stop():
	audio_stream_player.stop()
	is_playing = false
	modulate = Color.WHITE
	
func _on_play_button_pressed() -> void:
	play()
	play_button_pressed.emit(self)
	

func _on_pause_button_pressed() -> void:
	pause()
	pause_button_pressed.emit(self)
	
func _on_stop_button_pressed() -> void:
	stop()
	stop_button_pressed.emit(self)

func _on_song_finished() -> void:
	song_finished.emit(self)
