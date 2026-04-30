extends Node2D

@onready var world_time_label: Label = $UILayer/WorldTimeLabel


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _ready() -> void:
	WorldTimeService.time_tick.connect(_on_world_time_tick)
	_refresh_world_time_label()


func _on_world_time_tick(_day: int, _hour: int, _minute: int) -> void:
	_refresh_world_time_label()


func _refresh_world_time_label() -> void:
	world_time_label.text = WorldTimeService.get_current_time_string()
