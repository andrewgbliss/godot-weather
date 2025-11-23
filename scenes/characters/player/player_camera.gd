class_name PlayerCamera extends Camera2D

@export var min_zoom: float = 1.0
@export var max_zoom: float = 3.0

func _ready() -> void:
	call_deferred("_after_ready")

func _after_ready():
	set_zoom_level(GameManager.user_config.zoom_level)
	EventBus.zoom_level_changed.connect(_on_zoom_level_changed)

func _on_zoom_level_changed(zoom_level: float):
	set_zoom_level(zoom_level)

func set_zoom_level(zoom_level: float):
	var new_zoom = clamp(zoom_level, min_zoom, max_zoom)
	zoom = Vector2(new_zoom, new_zoom)
