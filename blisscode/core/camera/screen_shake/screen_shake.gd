extends Node2D

var camera: Camera2D
var shake_fade: float = 5.0
var noise_shake_speed: float = 10.0
var shake_strength: float = 0.0
var rand = RandomNumberGenerator.new()
var noise: FastNoiseLite = FastNoiseLite.new()
var noise_i: float = 0.0

func _ready():
	rand.randomize()
	noise.seed = rand.randi()
	noise.frequency = 1.0
	noise.fractal_octaves = 1
	noise.fractal_gain = 10
	noise.fractal_lacunarity = 20.0
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	
func apply_shake(amount: float, fade: float = 2.0, speed: float = 10.0):
	shake_fade = fade
	shake_strength = amount
	noise_shake_speed = speed
	camera = get_viewport().get_camera_2d()

func _process(delta: float) -> void:
	if camera != null:
		if shake_strength > 0.0:
			shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
			camera.offset = _get_random_noise(delta)

func _get_random_noise(delta: float):
	noise_i += delta * noise_shake_speed
	return Vector2(
		noise.get_noise_2d(1, noise_i) * shake_strength,
		noise.get_noise_2d(100, noise_i) * shake_strength
	)
