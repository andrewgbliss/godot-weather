class_name Weather extends Node2D

@export var particles: GPUParticles2D
@export var light_material: ParticleProcessMaterial
@export var heavy_material: ParticleProcessMaterial
@export var gravity_x: float = 0.0
@export var color_rect_overlay: ColorRect
@export var audio_player: AudioStreamPlayer

@export_range(0.0, 1.0) var moisture_min: float = 0.0
@export_range(0.0, 1.0) var moisture_max: float = 0.0
@export_range(0.0, 1.0) var temperature_min: float = 0.0
@export_range(0.0, 1.0) var temperature_max: float = 0.0
@export_range(0.0, 1.0) var altitude_min: float = 0.0
@export_range(0.0, 1.0) var altitude_max: float = 0.0
@export_range(0.0, 1.0) var barometer_min: float = 0.0
@export_range(0.0, 1.0) var barometer_max: float = 0.0
@export_range(0.0, 1.0) var wind_speed_min: float = 0.0
@export_range(0.0, 1.0) var wind_speed_max: float = 0.0

@export var time_to_fade: float = 10.0
@export var audio_fade_duration: float = 1.0

var is_active: bool = false
var _original_volume_db: float = 0.0
var _audio_fade_tween: Tween = null
var _volume_stored: bool = false

func _ready() -> void:
	if particles:
		particles.emitting = false
	hide()
	WeatherService.weather_changed.connect(_on_weather_changed)
	# Store original volume if audio player exists
	if audio_player:
		_original_volume_db = audio_player.volume_db
		_volume_stored = true


func _on_weather_changed(moisture: float, altitude: float, temperature: float, barometer: float, wind_speed: float, weather_direction: Vector2) -> void:
	var matches: bool = (
		moisture >= moisture_min and moisture <= moisture_max and
		temperature >= temperature_min and temperature <= temperature_max and
		altitude >= altitude_min and altitude <= altitude_max and
		barometer >= barometer_min and barometer <= barometer_max and
		wind_speed >= wind_speed_min and wind_speed <= wind_speed_max
	)

	if is_active:
		if not matches:
			stop()
		return
	
	if matches:
		start()

	match weather_direction:
		Vector2.LEFT:
			if light_material:
				light_material.gravity.x = - gravity_x
			if heavy_material:
				heavy_material.gravity.x = - gravity_x
			if color_rect_overlay:
				color_rect_overlay.material.set_shader_parameter("speed", Vector2(wind_speed / 10.0, 0.0))
		Vector2.RIGHT:
			if light_material:
				light_material.gravity.x = gravity_x
			if heavy_material:
				heavy_material.gravity.x = gravity_x
			if color_rect_overlay:
				color_rect_overlay.material.set_shader_parameter("speed", Vector2(-wind_speed / 10.0, 0.0))
		Vector2.ZERO:
			if light_material:
				light_material.gravity.x = 0
			if heavy_material:
				heavy_material.gravity.x = 0
			if color_rect_overlay:
				color_rect_overlay.material.set_shader_parameter("speed", Vector2(0.0, 0.0))
	
func start():
	is_active = true
	start_audio()
	if particles:
		particles.emitting = true
	show()
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	

func start_audio():
	if audio_player:
		# Store original volume if not already stored
		if not _volume_stored:
			_original_volume_db = audio_player.volume_db
			_volume_stored = true
		
		# Kill any existing fade tween
		if _audio_fade_tween:
			_audio_fade_tween.kill()
		
		# Start playing at silent volume
		audio_player.volume_db = -80
		audio_player.play()
		
		# Fade in to original volume
		_audio_fade_tween = create_tween()
		_audio_fade_tween.tween_property(audio_player, "volume_db", _original_volume_db, audio_fade_duration)

func stop():
	is_active = false
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func():
		if particles:
			particles.emitting = false
		hide()
	)
	stop_audio()

func stop_audio():
	if audio_player and audio_player.playing:
		# Kill any existing fade tween
		if _audio_fade_tween:
			_audio_fade_tween.kill()
		
		# Fade out to silent, then stop
		_audio_fade_tween = create_tween()
		_audio_fade_tween.tween_property(audio_player, "volume_db", -80, audio_fade_duration)
		_audio_fade_tween.tween_callback(func():
			audio_player.stop()
			# Reset volume for next time
			audio_player.volume_db = _original_volume_db
		)
		
func toggle():
	if particles:
		particles.emitting = !particles.emitting
