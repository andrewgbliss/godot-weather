extends CanvasModulate

@export var gradient: GradientTexture1D
@export var override_value: float = 0.3
@export_range(0.0, 10.0) var transition_speed: float = 2.0
@export_range(0.0, 1.0) var moisture_min: float = 0.0
@export_range(0.0, 1.0) var moisture_max: float = 0.0
@export_range(0.0, 1.0) var barometer_min: float = 0.0
@export_range(0.0, 1.0) var barometer_max: float = 0.0
@export_range(0.0, 1.0) var temperature_min: float = 0.0
@export_range(0.0, 1.0) var temperature_max: float = 0.0

var current_blend: float = 0.0

func _process(_delta: float) -> void:
	var normal_time_value = WorldTimeService.current_value
	var target_blend: float = 0.0
	
	# Check if ranges are configured
	if moisture_max > moisture_min and barometer_max > barometer_min:
		var current_moisture = WeatherService.get_moisture()
		var current_barometer = WeatherService.get_barometer()
		var current_temperature = WeatherService.get_temperature()
		
		# Simple check: are all values within their ranges?
		var moisture_in_range = current_moisture >= moisture_min and current_moisture <= moisture_max
		var barometer_in_range = current_barometer >= barometer_min and current_barometer <= barometer_max
		var temperature_in_range = true # Default to true if temperature range not set
		
		if temperature_max > temperature_min:
			temperature_in_range = current_temperature >= temperature_min and current_temperature <= temperature_max
		
		# If all conditions are met, target blend should be 1.0 (fully dark)
		if moisture_in_range and barometer_in_range and temperature_in_range:
			target_blend = 1.0
		else:
			target_blend = 0.0
	
	# Smoothly transition the blend factor
	current_blend = lerp(current_blend, target_blend, transition_speed * _delta)
	
	# Lerp between normal value and override value based on blend
	var time_value = lerp(normal_time_value, override_value, current_blend)
	
	# If the normal time value is already darker (lower) than override, use the time value
	if normal_time_value < override_value:
		time_value = normal_time_value
	
	color = gradient.gradient.sample(time_value)
