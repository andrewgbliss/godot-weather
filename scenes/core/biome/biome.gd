class_name Biome extends Node2D

@export var biome_environment: BiomeEnvironment
@export var world_environment: WorldEnvironment
@export var day_night_cycle: CanvasModulate
@export var weather_pattern_noise: FastNoiseLite
@export var weather_enabled: bool = false

var _update_timer: float = 0.0
var _weather_nodes: Array[Node] = []
var _value_directions: Dictionary = {}
var _next_direction_change_at: Dictionary = {}
var _wind_direction_x: float = -1.0
var _next_wind_direction_change_at: float = 0.0

signal weather_updated(biome_environment: BiomeEnvironment)

func _ready() -> void:
	_cache_weather_nodes()
	_initialize_random_walk_state()
	call_deferred("_after_ready")
	
func _after_ready():
	_update_weather(0.0)

func _cache_weather_nodes() -> void:
	_weather_nodes = get_tree().get_nodes_in_group("weather")

func _stop_weather() -> void:
	if weather_enabled:
		_update_timer = 0.0
		for w in _weather_nodes:
			if w != null and is_instance_valid(w) and w is Weather and w.is_active:
				w.stop()

func _process(delta: float) -> void:
	if weather_enabled:
		_update_weather(delta)
	else:
		_stop_weather()

func _update_weather(delta: float) -> void:
	_apply_wind_speed()

	biome_environment.set_moisture(
		_get_random_walk_value(
			"moisture",
			biome_environment.get_moisture(),
			biome_environment.moisture_min,
			biome_environment.moisture_max,
			biome_environment.moisture_wave,
			delta
		)
	)
	biome_environment.set_temperature(
		_get_random_walk_value(
			"temperature",
			biome_environment.get_temperature(),
			biome_environment.temperature_min,
			biome_environment.temperature_max,
			biome_environment.temperature_wave,
			delta
		)
	)
	biome_environment.set_barometer(
		_get_random_walk_value(
			"barometer",
			biome_environment.get_barometer(),
			biome_environment.barometer_min,
			biome_environment.barometer_max,
			biome_environment.barometer_wave,
			delta
		)
	)
	biome_environment.set_wind_speed(
		_get_random_walk_value(
			"wind_speed",
			biome_environment.get_wind_speed(),
			biome_environment.wind_speed_min,
			biome_environment.wind_speed_max,
			biome_environment.wind_speed_wave,
			delta
		)
	)
	biome_environment.set_static_energy(
		_get_random_walk_value(
			"static_energy",
			biome_environment.get_static_energy(),
			biome_environment.static_energy_min,
			biome_environment.static_energy_max,
			biome_environment.static_energy_wave,
			delta
		)
	)
	_update_weather_values()

	weather_updated.emit(biome_environment)

func _initialize_random_walk_state() -> void:
	var keys: Array[String] = ["moisture", "altitude", "temperature", "barometer", "wind_speed", "static_energy"]
	var now: float = WorldTimeService.time_elapsed
	for key in keys:
		_value_directions[key] = -1.0 if randf() < 0.5 else 1.0
		_next_direction_change_at[key] = now + randf_range(1.0, 5.0)
	_wind_direction_x = -1.0 if randf() < 0.5 else 1.0
	_next_wind_direction_change_at = now + randf_range(2.0, 7.0)

func _get_random_walk_value(key: String, current_value: float, range_min: float, range_max: float, wave: float, delta: float) -> float:
	var lo: float = minf(range_min, range_max)
	var hi: float = maxf(range_min, range_max)
	var wave_amount: float = clampf(wave, 0.0, 1.0)
	if is_zero_approx(wave_amount):
		return clampf(current_value, lo, hi)
	var now: float = WorldTimeService.time_elapsed
	var direction: float = _value_directions.get(key, 1.0)
	var next_change_at: float = _next_direction_change_at.get(key, 0.0)

	if now >= next_change_at:
		var flip_chance: float = lerpf(0.12, 0.35, wave_amount)
		if randf() < flip_chance:
			direction *= -1.0

		var base_interval: float = lerpf(20.0, 4.0, wave_amount)
		var variance: float = lerpf(8.0, 1.5, wave_amount)
		_next_direction_change_at[key] = now + base_interval + randf_range(0.0, variance)

	var step_per_second: float = lerpf(0.002, 0.08, pow(wave_amount, 1.2))
	var next_value: float = current_value + (direction * step_per_second * delta)

	if next_value <= lo:
		next_value = lo
		direction = 1.0
		_next_direction_change_at[key] = now + randf_range(2.0, 6.0)
	elif next_value >= hi:
		next_value = hi
		direction = -1.0
		_next_direction_change_at[key] = now + randf_range(2.0, 6.0)

	_value_directions[key] = direction
	return clampf(next_value, lo, hi)

func _update_weather_values() -> void:
	for w in _weather_nodes:
		if w != null and is_instance_valid(w) and w is Weather:
			w.set_weather(biome_environment)

func refresh_weather() -> void:
	_apply_wind_speed()
	_update_weather_values()
	weather_updated.emit(biome_environment)

func _apply_wind_speed() -> void:
	var direction: Vector2 = biome_environment.get_weather_direction()
	var wind_speed: float = biome_environment.get_wind_speed()
	for node in _weather_nodes:
		if node is Parallax2D:
			var parallax2d: Parallax2D = node
			var speed_offset: float = wind_speed * 2.0
			if wind_speed < 0.25:
				speed_offset = 0.0
			parallax2d.autoscroll = Vector2(direction.x * speed_offset, 0.0)
		if node is CanvasItem:
			var canvas_item: CanvasItem = node
			var speed_offset: float = -1.0 if direction.x < 0.0 else 1.0
			if wind_speed < 0.25:
				speed_offset = 0.0
			if canvas_item.material is ShaderMaterial:
				(canvas_item.material as ShaderMaterial).set_shader_parameter("speed", speed_offset)
