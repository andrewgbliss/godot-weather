class_name Hotspot extends Node2D

@onready var interact_area: Area2D = $InteractArea2D
@onready var in_range_area: Area2D = $InRangeArea2D
@onready var collision_area: Area2D = $CollisionArea2D
@onready var interact_audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

@export_group("Item")
@export var item: Item
@export var create_random_item: bool = false
@export var animation_name: String = "idle"
@export var start_animation: bool = false
@export var garbage_time: float = 1.0
@export var follow_target: bool = false
@export var follow_speed: float = 100.0
@export var snap_to_grid: int = 16

@export_group("Dialog")
@export var dialog_text: Array[String]
@export var dialog_image: Texture2D

@export_group("Interaction")
@export var interaction_text: String = "Press F To interact"
@export var interaction_offset: Vector2 = Vector2.ZERO
@export var body_group: String = "player"

@export_group("Settings")
@export var use_input: bool = false
@export var use_mouse: bool = false
@export var use_collision: bool = false

var in_range: bool = false
var local_collision_pos: Vector2
var current_body
var has_interacted = false
var is_mouse_over = false
var label: Label

signal interacted(body, pos: Vector2)
signal mouseover
signal mouseout
signal pickedup(item: Item, pos: Vector2)

func _ready():
	if create_random_item:
		item = ResourceStore.create_random_item()

	if in_range_area:
		in_range_area.body_entered.connect(_on_in_range_body_entered)
		in_range_area.body_exited.connect(_on_in_range_body_exited)
	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.input_event.connect(_on_input_event)
		interact_area.mouse_entered.connect(_on_mouse_entered)
		interact_area.mouse_exited.connect(_on_mouse_exited)

	if item:
		set_item(item)
	if start_animation and animation_player and animation_player.has_animation(animation_name):
		animation_player.play(animation_name)
	
	position = GameManager.snap_to_grid(position)

func _input(event):
	if not use_input:
		return
	if event is InputEventKey:
		if event.is_action_pressed("take"):
			var body = get_tree().get_first_node_in_group(body_group)
			if body:
				_interact_handler(body, global_position)
			else:
				print("No body found in group: ", body_group)

func _on_input_event(_viewport, _event, _shape_idx):
	if not use_mouse:
		return
	if Input.is_action_just_pressed("take"):
		var body = get_tree().get_first_node_in_group(body_group)
		if body:
			_interact_handler(body, get_global_mouse_position())
		else:
			print("No body found in group: ", body_group)

func _process(delta):
	if current_body and follow_target:
		var target_pos = current_body.get_global_position()
		var current_pos = get_global_position()
		var direction = (target_pos - current_pos).normalized()
		var new_pos = current_pos + direction * follow_speed * delta
		set_global_position(new_pos)

func _on_mouse_entered():
	if not in_range or not use_mouse:
		return
	is_mouse_over = true
	mouseover.emit()
	SpawnManager.float_text_stay("Click To interact", get_global_position() + interaction_offset)

func _on_mouse_exited():
	if not use_mouse:
		return
	is_mouse_over = false
	mouseout.emit()
	if label and is_instance_valid(label):
		SpawnManager.fade_out_text(label)

func _interact_handler(body, pos: Vector2):
	if not in_range or has_interacted:
		return
	if interact_audio:
		interact_audio.play()
	if label and is_instance_valid(label):
		SpawnManager.fade_out_text(label)
	has_interacted = true
	if item:
		_pickup_handler(body, pos)
	if dialog_text.size() > 0:
		DialogManager.show_dialog_bubble(dialog_text, pos, dialog_image)
	interacted.emit(body, pos)
		
func _integrate_forces(state):
	if (state.get_contact_count() >= 1):
		local_collision_pos = state.get_contact_local_pos(0)

func _on_in_range_body_entered(body):
	in_range = true
	current_body = body
	if interaction_text:
		label = await SpawnManager.float_text_stay(interaction_text, get_global_position() + interaction_offset)

func _on_in_range_body_exited(_body):
	in_range = false
	current_body = null
	has_interacted = false
	if label and is_instance_valid(label):
		SpawnManager.fade_out_text(label)

func _on_body_entered(body):
	if not use_collision:
		return
	var collision_position = local_collision_pos + get_position()
	_interact_handler(body, collision_position)

func set_item(new_item: Item):
	item = new_item
	sprite.texture = item.texture
	sprite.hframes = item.hframes
	sprite.vframes = item.vframes
	sprite.frame = item.frame
	if sprite and sprite.material:
		sprite.material.set_shader_parameter("rarity", item.rarity)
	
func _pickup_handler(body, pos: Vector2):
	if body is CharacterController:
		SpawnManager.float_text(item.name, pos)
		body.item_pickup(item, pos)
	pickedup.emit(item, pos)
	hide()
	await get_tree().create_timer(garbage_time).timeout
	call_deferred("queue_free")
