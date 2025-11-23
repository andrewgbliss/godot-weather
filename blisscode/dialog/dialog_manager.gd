extends Node2D

@export var dialog_world: DialogWorld
@export var dialog_bubble: DialogBubble

var dialog_world_queue = []
var dialog_queue = []
var is_showing = false
var is_showing_world = false

func _ready():
	dialog_world.dialogue_hidden.connect(on_dialog_hidden_world)
	dialog_bubble.dialogue_hidden.connect(on_dialog_hidden)

func _process(_delta):
	if not is_showing and dialog_queue.size() > 0:
		set_dialog(dialog_queue.pop_front())
	if not is_showing_world and dialog_world_queue.size() > 0:
		set_dialog_world(dialog_world_queue.pop_front())

func show_dialog_world(text: Array[String]):
	for t in text:
		dialog_world_queue.append({
			"text": t
		})

func show_dialog_bubble(text: Array[String], pos: Vector2, img: Texture2D = null):
	for t in text:
		dialog_queue.append({
			"text": t,
			"pos": pos,
			"img": img
		})

func set_dialog(data):
	is_showing = true
	dialog_bubble.show_dialog(data["text"], data["pos"], data["img"])

func set_dialog_world(data):
	is_showing_world = true
	dialog_world.show_dialog(data["text"])

func on_dialog_hidden():
	is_showing = false

func on_dialog_hidden_world():
	is_showing_world = false
