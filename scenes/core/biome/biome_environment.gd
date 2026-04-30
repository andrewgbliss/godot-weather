@tool

class_name BiomeEnvironment extends Resource

enum BiomeType {
	DEFAULT,
	BEACH,
	DESERT,
	OCEAN,
	GRASS,
	FOREST,
	MOUNTAINS,
	CAVE,
	SPACE,
	VOLCANO,
	RAIN,
	SNOW,
	FOG,
	WIND,
	LIGHTNING,
}

@export var biome_type: BiomeType = BiomeType.GRASS


@export_tool_button("Apply biome type min/max", "Callable")
var apply_biome_type_min_max: Callable = _editor_apply_biome_type_min_max

@export_group("Weather Ranges")
@export_range(0.0, 1.0) var moisture_min: float = 0.0
@export_range(0.0, 1.0) var moisture_max: float = 1.0
@export_range(0.0, 1.0) var altitude_min: float = 0.0
@export_range(0.0, 1.0) var altitude_max: float = 1.0
@export_range(0.0, 1.0) var temperature_min: float = 0.0
@export_range(0.0, 1.0) var temperature_max: float = 1.0
@export_range(0.0, 1.0) var barometer_min: float = 0.0
@export_range(0.0, 1.0) var barometer_max: float = 1.0
@export_range(0.0, 1.0) var wind_speed_min: float = 0.0
@export_range(0.0, 1.0) var wind_speed_max: float = 1.0
@export_range(0.0, 1.0) var static_energy_min: float = 0.0
@export_range(0.0, 1.0) var static_energy_max: float = 1.0

@export_group("Weather Waves")
@export_range(0.0, 1.0) var moisture_wave: float = 1.0
@export_range(0.0, 1.0) var altitude_wave: float = 1.0
@export_range(0.0, 1.0) var temperature_wave: float = 1.0
@export_range(0.0, 1.0) var barometer_wave: float = 1.0
@export_range(0.0, 1.0) var wind_speed_wave: float = 1.0
@export_range(0.0, 1.0) var static_energy_wave: float = 1.0

@export_group("Current Weather")
@export_range(0.0, 1.0) var moisture: float = 0.0:
	set = set_moisture, get = get_moisture

@export_range(0.0, 1.0) var altitude: float = 0.0:
	set = set_altitude, get = get_altitude

@export_range(0.0, 1.0) var temperature: float = 0.0:
	set = set_temperature, get = get_temperature

@export_range(0.0, 1.0) var barometer: float = 0.0:
	set = set_barometer, get = get_barometer

@export_range(0.0, 1.0) var wind_speed: float = 0.0:
	set = set_wind_speed, get = get_wind_speed

@export var weather_direction: Vector2 = Vector2.LEFT:
	set = set_weather_direction, get = get_weather_direction

@export_range(0.0, 1.0) var static_energy: float = 0.0:
	set = set_static_energy, get = get_static_energy

func get_moisture() -> float:
	return moisture

func set_moisture(value: float) -> void:
	moisture = _clamp_to_range(value, moisture_min, moisture_max)

func get_altitude() -> float:
	return altitude

func set_altitude(value: float) -> void:
	altitude = _clamp_to_range(value, altitude_min, altitude_max)

func get_temperature() -> float:
	return temperature

func set_temperature(value: float) -> void:
	temperature = _clamp_to_range(value, temperature_min, temperature_max)

func get_barometer() -> float:
	return barometer

func set_barometer(value: float) -> void:
	barometer = _clamp_to_range(value, barometer_min, barometer_max)

func get_wind_speed() -> float:
	return wind_speed

func set_wind_speed(value: float) -> void:
	wind_speed = _clamp_to_range(value, wind_speed_min, wind_speed_max)

func set_weather_direction(value: Vector2) -> void:
	weather_direction = value

func get_weather_direction() -> Vector2:
	return weather_direction

func get_static_energy() -> float:
	return static_energy

func set_static_energy(value: float) -> void:
	static_energy = _clamp_to_range(value, static_energy_min, static_energy_max)

func _clamp_to_range(value: float, range_min: float, range_max: float) -> float:
	var lo: float = minf(range_min, range_max)
	var hi: float = maxf(range_min, range_max)
	return clampf(value, lo, hi)

func _clamp_all_weather_values() -> void:
	set_moisture(moisture)
	set_altitude(altitude)
	set_temperature(temperature)
	set_barometer(barometer)
	set_wind_speed(wind_speed)
	set_static_energy(static_energy)

func _editor_apply_biome_type_min_max() -> void:
	_apply_min_max_for_biome_type(biome_type)
	_clamp_all_weather_values()
	if Engine.is_editor_hint():
		notify_property_list_changed()

func _apply_min_max_for_biome_type(t: BiomeType) -> void:
	match t:
		BiomeType.DEFAULT:
			moisture_min = 0.0
			moisture_max = 1.0
			altitude_min = 0.0
			altitude_max = 1.0
			temperature_min = 0.0
			temperature_max = 1.0
			barometer_min = 0.0
			barometer_max = 1.0
			wind_speed_min = 0.0
			wind_speed_max = 0.0
			static_energy_min = 0.0
			static_energy_max = 1.0
		BiomeType.BEACH:
			moisture_min = 0.45
			moisture_max = 0.85
			altitude_min = 0.0
			altitude_max = 0.25
			temperature_min = 0.55
			temperature_max = 0.92
			barometer_min = 0.38
			barometer_max = 0.68
			wind_speed_min = 0.28
			wind_speed_max = 0.72
			static_energy_min = 0.0
			static_energy_max = 1.0
		BiomeType.DESERT:
			moisture_min = 0.0
			moisture_max = 0.18
			altitude_min = 0.1
			altitude_max = 0.85
			temperature_min = 0.7
			temperature_max = 1.0
			barometer_min = 0.52
			barometer_max = 0.88
			wind_speed_min = 0.12
			wind_speed_max = 0.48
			static_energy_min = 0.0
			static_energy_max = 1.0
		BiomeType.OCEAN:
			moisture_min = 0.78
			moisture_max = 1.0
			altitude_min = 0.0
			altitude_max = 0.12
			temperature_min = 0.32
			temperature_max = 0.62
			barometer_min = 0.28
			barometer_max = 0.78
			wind_speed_min = 0.45
			wind_speed_max = 1.0
			static_energy_min = 0.0
			static_energy_max = 1.0
		BiomeType.GRASS:
			moisture_min = 0.32
			moisture_max = 0.68
			altitude_min = 0.12
			altitude_max = 0.48
			temperature_min = 0.42
			temperature_max = 0.72
			barometer_min = 0.36
			barometer_max = 0.72
			wind_speed_min = 0.22
			wind_speed_max = 0.58
			static_energy_min = 0.0
			static_energy_max = 1.0
		BiomeType.FOREST:
			moisture_min = 0.52
			moisture_max = 0.92
			altitude_min = 0.22
			altitude_max = 0.58
			temperature_min = 0.38
			temperature_max = 0.68
			barometer_min = 0.42
			barometer_max = 0.76
			wind_speed_min = 0.12
			wind_speed_max = 0.42
			static_energy_min = 0.0
			static_energy_max = 1.0
		BiomeType.MOUNTAINS:
			moisture_min = 0.25
			moisture_max = 1.0
			altitude_min = 0.5
			altitude_max = 1.0
			temperature_min = 0.0
			temperature_max = 0.5
			barometer_min = 0.0
			barometer_max = 1.0
			wind_speed_min = 0.0
			wind_speed_max = 1.0
			static_energy_min = 0.0
			static_energy_max = 1.0
		BiomeType.CAVE:
			moisture_min = 0.0
			moisture_max = 0.18
			altitude_min = 0.1
			altitude_max = 0.85
			temperature_min = 0.7
			temperature_max = 1.0
			barometer_min = 0.52
			barometer_max = 0.88
			wind_speed_min = 0.12
			wind_speed_max = 0.48
			static_energy_min = 0.0
			static_energy_max = 1.0
		BiomeType.SPACE:
			moisture_min = 0.0
			moisture_max = 0.18
			altitude_min = 0.1
			altitude_max = 0.85
			temperature_min = 0.7
			temperature_max = 1.0
			barometer_min = 0.52
			barometer_max = 0.88
			wind_speed_min = 0.12
			wind_speed_max = 0.48
			static_energy_min = 0.0
			static_energy_max = 1.0
		BiomeType.VOLCANO:
			moisture_min = 0.0
			moisture_max = 0.18
			altitude_min = 0.1
			altitude_max = 0.85
			temperature_min = 0.7
			temperature_max = 1.0
			barometer_min = 0.52
			barometer_max = 0.88
			wind_speed_min = 0.12
			wind_speed_max = 0.48
			static_energy_min = 0.0
			static_energy_max = 1.0
		BiomeType.RAIN:
			moisture_min = 0.75
			moisture_max = 1.0
			altitude_min = 0.0
			altitude_max = 1.0
			temperature_min = 0.25
			temperature_max = 1.0
			barometer_min = 0.0
			barometer_max = 0.25
			wind_speed_min = 0.0
			wind_speed_max = 1.0
			static_energy_min = 0.0
			static_energy_max = 1.0
		BiomeType.SNOW:
			moisture_min = 0.75
			moisture_max = 1.0
			altitude_min = 0.0
			altitude_max = 1.0
			temperature_min = 0.0
			temperature_max = 0.25
			barometer_min = 0.0
			barometer_max = 0.25
			wind_speed_min = 0.0
			wind_speed_max = 1.0
			static_energy_min = 0.0
			static_energy_max = 1.0
		BiomeType.FOG:
			moisture_min = 0.75
			moisture_max = 1.0
			altitude_min = 0.0
			altitude_max = 1.0
			temperature_min = 0.0
			temperature_max = 1.0
			barometer_min = 0.0
			barometer_max = 0.25
			wind_speed_min = 0.0
			wind_speed_max = 1.0
			static_energy_min = 0.0
			static_energy_max = 1.0
		BiomeType.WIND:
			moisture_min = 0.0
			moisture_max = 1.0
			altitude_min = 0.0
			altitude_max = 1.0
			temperature_min = 0.0
			temperature_max = 1.0
			barometer_min = 0.0
			barometer_max = 1.0
			wind_speed_min = 0.5
			wind_speed_max = 1.0
			static_energy_min = 0.0
			static_energy_max = 1.0
		BiomeType.LIGHTNING:
			moisture_min = 0.75
			moisture_max = 1.0
			altitude_min = 0.0
			altitude_max = 1.0
			temperature_min = 0.0
			temperature_max = 1.0
			barometer_min = 0.0
			barometer_max = 0.25
			wind_speed_min = 0.0
			wind_speed_max = 1.0
			static_energy_min = 0.75
			static_energy_max = 1.0
		_:
			pass
