extends Control

@export var biome: Biome

@onready var weather_panel: PanelContainer = %WeatherPanel
@onready var show_hide_toggle_button: LinkButton = %ShowHideToggle
@onready var biome_label: Label = %BiomeValue
@onready var moisture_slider: HSlider = %Moisture
@onready var altitude_slider: HSlider = %Altitude
@onready var temperature_slider: HSlider = %Temperature
@onready var barometer_slider: HSlider = %Barometer
@onready var wind_speed_slider: HSlider = %WindSpeed
@onready var static_energy_slider: HSlider = %StaticEnergy
@onready var wind_direction_left_button: Button = %WindDirectionLeft
@onready var wind_direction_right_button: Button = %WindDirectionRight
@onready var weather_enabled_checkbox: CheckBox = %WeatherEnabled

var _is_syncing_ui: bool = false
var _controls_visible: bool = true

func _ready() -> void:
	show_hide_toggle_button.pressed.connect(_on_show_hide_toggle_pressed)
	_set_controls_visible(true)
	if not biome:
		return
	biome.weather_updated.connect(_sync_from_environment)
	_connect_value_signals()
	_sync_from_environment(biome.biome_environment)

func _on_show_hide_toggle_pressed() -> void:
	_set_controls_visible(not _controls_visible)

func _set_controls_visible(should_show_controls: bool) -> void:
	_controls_visible = should_show_controls
	show_hide_toggle_button.text = "Hide" if _controls_visible else "Show"
	weather_panel.visible = should_show_controls

func _connect_value_signals() -> void:
	var controls: Array[HSlider] = [
		moisture_slider,
		altitude_slider,
		temperature_slider,
		barometer_slider,
		wind_speed_slider,
		static_energy_slider,
	]
	for control in controls:
		control.value_changed.connect(_on_current_value_changed)
	weather_enabled_checkbox.toggled.connect(_on_weather_enabled_toggled)
	wind_direction_left_button.pressed.connect(_on_wind_direction_left_pressed)
	wind_direction_right_button.pressed.connect(_on_wind_direction_right_pressed)
	biome.weather_toggled.connect(_on_weather_toggled)

func _on_weather_enabled_toggled(is_enabled: bool) -> void:
	if _is_syncing_ui:
		return
	if not biome:
		return
	biome.weather_enabled = is_enabled


func _on_current_value_changed(_value: float) -> void:
	if _is_syncing_ui:
		return
	if not biome or not biome.biome_environment:
		return
	var env: BiomeEnvironment = biome.biome_environment
	env.set_moisture(moisture_slider.value)
	env.set_altitude(altitude_slider.value)
	env.set_temperature(temperature_slider.value)
	env.set_barometer(barometer_slider.value)
	env.set_wind_speed(wind_speed_slider.value)
	env.set_static_energy(static_energy_slider.value)

	biome.refresh_weather()

func _on_wind_direction_left_pressed() -> void:
	_set_wind_direction(-1.0)

func _on_wind_direction_right_pressed() -> void:
	_set_wind_direction(1.0)

func _set_wind_direction(direction_x: float) -> void:
	if _is_syncing_ui:
		return
	if not biome or not biome.biome_environment:
		return
	biome.biome_environment.set_weather_direction(Vector2(direction_x, 0.0))
	biome.refresh_weather()

func _sync_from_environment(biome_environment: BiomeEnvironment) -> void:
	_is_syncing_ui = true
	biome_label.text = _biome_type_to_string(biome_environment.biome_type)
	if biome:
		weather_enabled_checkbox.button_pressed = biome.weather_enabled
	moisture_slider.value = biome_environment.get_moisture()
	altitude_slider.value = biome_environment.get_altitude()
	temperature_slider.value = biome_environment.get_temperature()
	barometer_slider.value = biome_environment.get_barometer()
	wind_speed_slider.value = biome_environment.get_wind_speed()
	static_energy_slider.value = biome_environment.get_static_energy()
	var direction_x: float = biome_environment.get_weather_direction().x
	wind_direction_left_button.button_pressed = direction_x < 0.0
	wind_direction_right_button.button_pressed = direction_x > 0.0
	_is_syncing_ui = false

func _biome_type_to_string(type: BiomeEnvironment.BiomeType) -> String:
	var raw_name: String = BiomeEnvironment.BiomeType.keys()[type]
	return raw_name.capitalize()

func _on_weather_toggled(is_enabled: bool) -> void:
	weather_enabled_checkbox.button_pressed = is_enabled
