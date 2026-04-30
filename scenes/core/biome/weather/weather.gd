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
@export var audio_repeat_time: float = 0.0
@export var sprite: Sprite2D

var is_active: bool = false
var _original_volume_db: float = 0.0
var _audio_fade_tween: Tween = null
var _audio_repeat_timer: Timer = null
var _visual_fade_tween: Tween = null
var _sprite_base_alpha: float = 1.0
var _overlay_base_alpha: float = 1.0

func _ready() -> void:
	if particles:
		particles.emitting = false
	if sprite:
		_sprite_base_alpha = sprite.modulate.a
	if color_rect_overlay:
		_overlay_base_alpha = color_rect_overlay.modulate.a
	hide()
	if audio_player:
		_original_volume_db = audio_player.volume_db
	_setup_audio_repeat_timer()


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
	is_active = true
	start_audio()
	_start_audio_repeat_timer()
	_visual_fade_tween = _create_visual_fade_tween()
	if particles:
		particles.emitting = true
	show()
	modulate.a = 0.0
	_fade_canvas_item(self, 1.0)
	_fade_canvas_item(sprite, _sprite_base_alpha, true)
	_fade_canvas_item(color_rect_overlay, _overlay_base_alpha, true)
	

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
	is_active = false
	_stop_audio_repeat_timer()
	_visual_fade_tween = _create_visual_fade_tween()
	_fade_canvas_item(self, 0.0)
	_fade_canvas_item(sprite, 0.0)
	_fade_canvas_item(color_rect_overlay, 0.0)
	_visual_fade_tween.tween_callback(_on_stop_visual_fade_finished)
	stop_audio()

func _create_visual_fade_tween() -> Tween:
	if _visual_fade_tween:
		_visual_fade_tween.kill()
	return create_tween()

func _fade_canvas_item(item: CanvasItem, target_alpha: float, reveal: bool = false) -> void:
	if not item:
		return
	if reveal:
		item.show()
		item.modulate.a = 0.0
	_visual_fade_tween.parallel().tween_property(item, "modulate:a", target_alpha, time_to_fade)

func _on_stop_visual_fade_finished() -> void:
	if particles:
		particles.emitting = false
	if sprite:
		sprite.hide()
		sprite.modulate.a = _sprite_base_alpha
	if color_rect_overlay:
		color_rect_overlay.hide()
		color_rect_overlay.modulate.a = _overlay_base_alpha
	hide()
	_visual_fade_tween = null

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

func _setup_audio_repeat_timer() -> void:
	_audio_repeat_timer = Timer.new()
	_audio_repeat_timer.one_shot = false
	_audio_repeat_timer.autostart = false
	_audio_repeat_timer.timeout.connect(_on_audio_repeat_timeout)
	add_child(_audio_repeat_timer)

func _start_audio_repeat_timer() -> void:
	if not _audio_repeat_timer:
		return
	if audio_repeat_time > 0.0:
		_audio_repeat_timer.wait_time = audio_repeat_time
		_audio_repeat_timer.start()
	else:
		_audio_repeat_timer.stop()

func _stop_audio_repeat_timer() -> void:
	if _audio_repeat_timer:
		_audio_repeat_timer.stop()

func _on_audio_repeat_timeout() -> void:
	if not is_active or audio_repeat_time <= 0.0:
		return
	if audio_player and not audio_player.playing:
		start_audio()
		
func toggle():
	if particles:
		particles.emitting = !particles.emitting
