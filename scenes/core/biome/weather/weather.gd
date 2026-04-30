class_name Weather extends Node2D

@export var biome_environment: BiomeEnvironment
@export var particles: GPUParticles2D
@export var light_material: ParticleProcessMaterial
@export var heavy_material: ParticleProcessMaterial
@export var gravity_x: float = 0.0
@export var color_rect_overlay: ColorRect
@export var audio_player: AudioStreamPlayer
@export var time_to_fade: float = 10.0
@export var audio_fade_duration: float = 1.0
@export var sprite: Sprite2D

var is_active: bool = false
var _original_volume_db: float = 0.0
var _audio_fade_tween: Tween = null

func _ready() -> void:
	if particles:
		particles.emitting = false
	hide()
	if audio_player:
		_original_volume_db = audio_player.volume_db


func set_weather(current_biome_environment: BiomeEnvironment) -> void:
	var moisture: float = current_biome_environment.get_moisture()
	var temperature: float = current_biome_environment.get_temperature()
	var altitude: float = current_biome_environment.get_altitude()
	var barometer: float = current_biome_environment.get_barometer()
	var wind_speed: float = current_biome_environment.get_wind_speed()
	var weather_direction: Vector2 = current_biome_environment.get_weather_direction()
	var static_energy: float = current_biome_environment.get_static_energy()

	var matches: bool = (
		moisture >= biome_environment.moisture_min and moisture <= biome_environment.moisture_max and
		temperature >= biome_environment.temperature_min and temperature <= biome_environment.temperature_max and
		altitude >= biome_environment.altitude_min and altitude <= biome_environment.altitude_max and
		barometer >= biome_environment.barometer_min and barometer <= biome_environment.barometer_max and
		wind_speed >= biome_environment.wind_speed_min and wind_speed <= biome_environment.wind_speed_max and
		static_energy >= biome_environment.static_energy_min and static_energy <= biome_environment.static_energy_max
	)

	if not matches:
		stop()
		return

	if not is_active:
		start()

	match weather_direction:
		Vector2.LEFT:
			if light_material:
				light_material.gravity.x = - gravity_x
			if heavy_material:
				heavy_material.gravity.x = - gravity_x
			if color_rect_overlay:
				color_rect_overlay.material.set_shader_parameter("speed", Vector2(0.005, 0.0))
		Vector2.RIGHT:
			if light_material:
				light_material.gravity.x = gravity_x
			if heavy_material:
				heavy_material.gravity.x = gravity_x
			if color_rect_overlay:
				color_rect_overlay.material.set_shader_parameter("speed", Vector2(-0.005, 0.0))
		Vector2.ZERO:
			if light_material:
				light_material.gravity.x = 0
			if heavy_material:
				heavy_material.gravity.x = 0
			if color_rect_overlay:
				color_rect_overlay.material.set_shader_parameter("speed", Vector2(0.0, 0.0))

	if particles:
		if wind_speed > 0.5:
			particles.process_material = heavy_material
		else:
			particles.process_material = light_material
	
func start():
	if is_active:
		return
	# print("start ", name)
	is_active = true
	start_audio()
	if particles:
		particles.emitting = true
	if color_rect_overlay:
		color_rect_overlay.show()
	if sprite:
		sprite.show()
	show()
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self , "modulate:a", 1.0, 1.0)
	

func start_audio():
	if audio_player:
		if _audio_fade_tween:
			_audio_fade_tween.kill()

		audio_player.volume_db = -80
		audio_player.play()

		_audio_fade_tween = create_tween()
		_audio_fade_tween.tween_property(audio_player, "volume_db", _original_volume_db, audio_fade_duration)

func stop():
	if not is_active:
		return
	# print("stop ", name)
	is_active = false
	var tween = create_tween()
	tween.tween_property(self , "modulate:a", 0.0, 1.0)
	tween.tween_callback(func():
		if particles:
			particles.emitting = false
		if sprite:
			sprite.hide()
		if color_rect_overlay:
			color_rect_overlay.hide()
		hide()
	)
	stop_audio()

func stop_audio():
	if audio_player and audio_player.playing:
		if _audio_fade_tween:
			_audio_fade_tween.kill()
		
		_audio_fade_tween = create_tween()
		_audio_fade_tween.tween_property(audio_player, "volume_db", -80, audio_fade_duration)
		_audio_fade_tween.tween_callback(func():
			audio_player.stop()
			audio_player.volume_db = _original_volume_db
		)
		
func toggle():
	if particles:
		particles.emitting = !particles.emitting
