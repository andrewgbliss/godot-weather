class_name FogOfWar extends Node2D

@export var fog_sprite: Sprite2D
@export var tiles: TileMapLayer
@export var player: CharacterBody2D
@export var fog_pixelation: int = 16

var fog_image: Image
var vision_image: Image
var world_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	_generate_fog()
	update_fog()

func _process(_delta: float) -> void:
	if player.velocity.length() > 0:
		update_fog()

func _generate_fog() -> void:
	var world_dimensions = tiles.get_used_rect().size * tiles.tile_set.tile_size
	world_position = tiles.get_used_rect().position * tiles.tile_set.tile_size
	var scaled_dimensions = world_dimensions / fog_pixelation
	fog_image = Image.create(scaled_dimensions.x, scaled_dimensions.y, false, Image.FORMAT_RGBAH)
	fog_image.fill(Color.BLACK)
	var fog_texture = ImageTexture.create_from_image(fog_image)
	fog_sprite.texture = fog_texture
	fog_sprite.scale *= fog_pixelation

	vision_image = player.vision_sprite.texture.get_image()
	vision_image.convert(Image.FORMAT_RGBAH)

	var vision_scale = Vector2(vision_image.get_size()) / fog_pixelation
	vision_image.resize(vision_scale.x, vision_scale.y, Image.INTERPOLATE_NEAREST)

func update_fog() -> void:
	var vision_rect = Rect2(Vector2.ZERO, vision_image.get_size())
	fog_image.blend_rect(
		vision_image,
		vision_rect,
		(player.global_position / fog_pixelation) - (world_position / fog_pixelation) - Vector2(vision_image.get_size() / 2)
	)
	var fog_texture = ImageTexture.create_from_image(fog_image)
	fog_sprite.texture = fog_texture
