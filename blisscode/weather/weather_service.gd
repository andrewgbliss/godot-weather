extends Node

@export_range(0.0, 1.0) var moisture: float = 0.0:
	set = set_moisture, get = get_moisture

func get_moisture() -> float:
	return moisture

func set_moisture(value: float) -> void:
	moisture = value

@export_range(0.0, 1.0) var altitude: float = 0.0:
	set = set_altitude, get = get_altitude

func get_altitude() -> float:
	return altitude

func set_altitude(value: float) -> void:
	altitude = value

@export_range(0.0, 1.0) var temperature: float = 0.0:
	set = set_temperature, get = get_temperature

func get_temperature() -> float:
	return temperature

func set_temperature(value: float) -> void:
	temperature = value

@export_range(0.0, 1.0) var barometer: float = 0.0:
	set = set_barometer, get = get_barometer

func get_barometer() -> float:
	return barometer

func set_barometer(value: float) -> void:
	barometer = value

@export_range(0.0, 1.0) var wind_speed: float = 0.0:
	set = set_wind_speed, get = get_wind_speed

func get_wind_speed() -> float:
	return wind_speed

func set_wind_speed(value: float) -> void:
	wind_speed = value

@export var weather_direction: Vector2 = Vector2.LEFT:
	set = set_weather_direction, get = get_weather_direction

func set_weather_direction(value: Vector2) -> void:
	weather_direction = value
	

func get_weather_direction() -> Vector2:
	return weather_direction

@export var debug_panel: Panel
@export var weather_pattern_noise: FastNoiseLite
@export var moisture_slider: HSlider
@export var altitude_slider: HSlider
@export var temperature_slider: HSlider
@export var barometer_slider: HSlider
@export var wind_speed_slider: HSlider

signal weather_changed(moisture: float, altitude: float, temperature: float, barometer: float, wind_speed: float, weather_direction: Vector2)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		if debug_panel.visible:
			debug_panel.hide()
		else:
			debug_panel.show()

var _update_timer: float = 0.0
var _time_elapsed: float = 0.0
var _noise_time: float = 0.0
const UPDATE_INTERVAL: float = 5.0

func _ready() -> void:
	debug_panel.hide()

func _process(delta: float) -> void:
	_update_weather(delta)

func _update_weather(delta: float) -> void:
	if not weather_pattern_noise:
		return
		
	_update_timer += delta
	_time_elapsed += delta
	
	if _update_timer >= UPDATE_INTERVAL:
		_update_timer -= UPDATE_INTERVAL
		# Increment noise time each update to ensure values change
		_noise_time += 1.0
		# Use different noise coordinates for each parameter to get varied values
		var time_scale: float = _noise_time * 0.1
		
		var did_update: bool = false
		# Randomly update one parameter at a time (excluding altitude)
		match randi() % 10:
			0: # Moisture
				set_moisture((weather_pattern_noise.get_noise_2d(time_scale, time_scale + 100.0) + 1.0) / 2.0)
				did_update = true
			1: # Temperature
				set_temperature((weather_pattern_noise.get_noise_2d(time_scale + 400.0, time_scale + 500.0) + 1.0) / 2.0)
				did_update = true
			2: # Barometer
				set_barometer((weather_pattern_noise.get_noise_2d(time_scale + 600.0, time_scale + 700.0) + 1.0) / 2.0)
				did_update = true
			3: # Wind Speed
				set_wind_speed((weather_pattern_noise.get_noise_2d(time_scale + 800.0, time_scale + 900.0) + 1.0) / 2.0)
				did_update = true
			_:
				pass
		
		if did_update:
			_update_sliders()
			weather_changed.emit(get_moisture(), get_altitude(), get_temperature(), get_barometer(), get_wind_speed(), get_weather_direction())

func _update_sliders() -> void:
	moisture_slider.value = get_moisture()
	altitude_slider.value = get_altitude()
	temperature_slider.value = get_temperature()
	barometer_slider.value = get_barometer()
	wind_speed_slider.value = get_wind_speed()

func get_weather() -> Dictionary:
	return {
		"moisture": moisture,
		"altitude": altitude,
		"temperature": temperature,
		"barometer": barometer,
		"wind_speed": wind_speed,
		"weather_direction": weather_direction
	}

func _on_right_weather_button_pressed() -> void:
	set_weather_direction(Vector2.RIGHT)
	weather_changed.emit(get_moisture(), get_altitude(), get_temperature(), get_barometer(), get_wind_speed(), get_weather_direction())

func _on_down_weather_button_pressed() -> void:
	set_weather_direction(Vector2.ZERO)
	weather_changed.emit(get_moisture(), get_altitude(), get_temperature(), get_barometer(), get_wind_speed(), get_weather_direction())

func _on_left_weather_button_pressed() -> void:
	set_weather_direction(Vector2.LEFT)
	weather_changed.emit(get_moisture(), get_altitude(), get_temperature(), get_barometer(), get_wind_speed(), get_weather_direction())

func _on_moisture_h_slider_value_changed(value: float) -> void:
	set_moisture(value)
	weather_changed.emit(get_moisture(), get_altitude(), get_temperature(), get_barometer(), get_wind_speed(), get_weather_direction())

func _on_altitude_h_slider_value_changed(value: float) -> void:
	set_altitude(value)
	weather_changed.emit(get_moisture(), get_altitude(), get_temperature(), get_barometer(), get_wind_speed(), get_weather_direction())

func _on_temp_h_slider_value_changed(value: float) -> void:
	set_temperature(value)
	weather_changed.emit(get_moisture(), get_altitude(), get_temperature(), get_barometer(), get_wind_speed(), get_weather_direction())

func _on_barometer_h_slider_value_changed(value: float) -> void:
	set_barometer(value)
	weather_changed.emit(get_moisture(), get_altitude(), get_temperature(), get_barometer(), get_wind_speed(), get_weather_direction())

func _on_wind_h_slider_value_changed(value: float) -> void:
	set_wind_speed(value)
	weather_changed.emit(get_moisture(), get_altitude(), get_temperature(), get_barometer(), get_wind_speed(), get_weather_direction())
