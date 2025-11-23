class_name RoomFiller extends Node2D

@export var altitude_scenes: Array[PackedScene]
@export var temperature_scenes: Array[PackedScene]
@export var moisture_scenes: Array[PackedScene]
@export var width = 1200
@export var height = 800
@export var spacing = 32 # Add spacing parameter
@export var temperature_threshold: float = 0
@export var moisture_threshold: float = 0
@export var altitude_threshold: float = 0

var temperature = FastNoiseLite.new()
var moisture = FastNoiseLite.new()
var altitude = FastNoiseLite.new()

var enemies = []
var max_enemies = 0

signal enemies_killed(count: int, max_count: int)

func _ready():
	call_deferred("generate_room")

func generate_room():
	temperature.seed = randi();
	moisture.seed = randi();
	altitude.seed = randi();
	altitude.frequency = 0.05
	var center_x = position.x - width / 2.0
	var center_y = position.y - height / 2.0
	
	# Use step to create spacing between objects
	for x in range(0, width, spacing):
		var x_offset = center_x + x
		for y in range(0, height, spacing):
			var y_offset = center_y + y
			var moist = moisture.get_noise_2d(x_offset, y_offset)
			var temp = temperature.get_noise_2d(x_offset, y_offset)
			var alt = altitude.get_noise_2d(x_offset, y_offset)
		
			var scene_to_use = select_scene_based_on_conditions(alt, temp, moist)
			if scene_to_use != null:
				var instance = scene_to_use.instantiate()
				instance.position = Vector2(x_offset, y_offset)
				if instance is CharacterController:
					instance.died.connect(_on_enemy_death)
					add_child(instance)
					instance.spawn(instance.position)
					enemies.append(instance)
				else:
					add_child(instance)
				
	
	max_enemies = enemies.size()
	enemies_killed.emit(enemies.size(), max_enemies)

func _on_enemy_death(enemy: CharacterController):
	enemies.erase(enemy)
	enemies_killed.emit(enemies.size(), max_enemies)

func select_scene_based_on_conditions(alt: float, temp: float, moist: float) -> PackedScene:
	# Priority order: altitude > temperature > moisture > default
	# Check altitude first
	if alt < altitude_threshold and altitude_scenes.size() > 0:
		return altitude_scenes[randi() % altitude_scenes.size()]
	
	# Check temperature
	if temp < temperature_threshold and temperature_scenes.size() > 0:
		return temperature_scenes[randi() % temperature_scenes.size()]
	
	# Check moisture
	if moist < moisture_threshold and moisture_scenes.size() > 0:
		return moisture_scenes[randi() % moisture_scenes.size()]
	
	return null
				
func between(val, start, end):
	return start <= val and val < end
