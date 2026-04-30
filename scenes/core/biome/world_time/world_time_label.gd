extends Label

func _ready() -> void:
	WorldTimeService.time_tick.connect(_on_world_time_tick)
	_refresh_world_time_label()

func _on_world_time_tick(_day: int, _hour: int, _minute: int) -> void:
	_refresh_world_time_label()

func _refresh_world_time_label() -> void:
	text = WorldTimeService.get_current_time_string()
