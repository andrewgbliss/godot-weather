class_name WeatherEnableArea extends Area2D

@export var biome: Biome
@export var biome_environment: BiomeEnvironment

var prev_biome_environment: BiomeEnvironment = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(_body: Node2D) -> void:
	prev_biome_environment = biome.biome_environment.duplicate()
	biome.update_values_from_environment(biome_environment)
	biome.weather_enabled = true
	biome.weather_toggled.emit(true)

func _on_body_exited(_body: Node2D) -> void:
	if prev_biome_environment:
		prev_biome_environment.print_debug()
		biome.update_values_from_environment(prev_biome_environment.duplicate())
		prev_biome_environment = null
	biome.weather_enabled = false
	biome.weather_toggled.emit(false)
