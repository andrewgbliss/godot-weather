extends Node

@export var choice_1 = Label
@export var choice_2 = Label
@export var choice_3 = Label
@export var right_arrow_1 = TextureRect
@export var right_arrow_2 = TextureRect
@export var right_arrow_3 = TextureRect

@onready var canvas_layer = $CanvasLayer
@onready var animation_player = $AnimationPlayer

enum State {
	IDLE,
	SHOWING_UI,
	SHOWING_CHOICES,
	SHOWING_CURSOR,
}

var timer = 0.0
var state = State.IDLE

signal choices_finished(choice_index: int)

var is_running = false
var choice_selected_index = 0
var choices

func _ready() -> void:
	start([
		{"text": "Choice 1 -> Scene 1", "next_scene": "Scene 1"},
		{"text": "Choice 2 -> Scene 2", "next_scene": "Scene 2"},
		{"text": "Choice 3 -> Scene 3", "next_scene": "Scene 3"}
	])


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		timer = 0.0
	elif state == State.SHOWING_CURSOR:
		if Input.is_action_just_pressed("ui_up"):
			_set_selected_index(-1)
		elif Input.is_action_just_pressed("ui_down"):
			_set_selected_index(1)
		elif Input.is_action_just_pressed("ui_accept"):
			_on_choice_selected()

func _process(delta):
	if not is_running:
		return
	match state:
		State.IDLE:
			_idle()
		State.SHOWING_UI:
			_showing_ui()
		State.SHOWING_CHOICES:
			_showing_choices(delta)
		State.SHOWING_CURSOR:
			_showing_cursor(delta)

func _set_selected_index(index: int):
	choice_selected_index += index
	if choice_selected_index < 0:
		choice_selected_index = 2
	if choice_selected_index > 2:
		choice_selected_index = 0
		
	right_arrow_1.modulate = Color.TRANSPARENT
	right_arrow_2.modulate = Color.TRANSPARENT
	right_arrow_3.modulate = Color.TRANSPARENT

	match choice_selected_index:
		0:
			choice_1.modulate = Color.WHITE
			choice_2.modulate = Color.GRAY
			choice_3.modulate = Color.GRAY
			right_arrow_1.modulate = Color.WHITE
			right_arrow_2.modulate = Color.TRANSPARENT
			right_arrow_3.modulate = Color.TRANSPARENT

		1:
			choice_1.modulate = Color.GRAY
			choice_2.modulate = Color.WHITE
			choice_3.modulate = Color.GRAY
			right_arrow_1.modulate = Color.TRANSPARENT
			right_arrow_2.modulate = Color.WHITE
			right_arrow_3.modulate = Color.TRANSPARENT
		2:
			choice_1.modulate = Color.GRAY
			choice_2.modulate = Color.GRAY
			choice_3.modulate = Color.WHITE
			right_arrow_1.modulate = Color.TRANSPARENT
			right_arrow_2.modulate = Color.TRANSPARENT
			right_arrow_3.modulate = Color.WHITE

func _idle():
	state = State.SHOWING_UI

func _showing_ui():
	_show_ui()
	state = State.SHOWING_CHOICES
	timer = .25

func _showing_choices(delta):
	timer -= delta
	if timer <= 0.0:
		_show_choices()
		state = State.SHOWING_CURSOR
		timer = .25

func _showing_cursor(delta):
	timer -= delta
	if timer <= 0.0:
		_set_selected_index(0)

func _show_ui():
	choice_1.text = ""
	choice_2.text = ""
	choice_3.text = ""
	animation_player.play("fade_in")

func _hide_ui():
	animation_player.play("fade_out")
	choice_1.text = ""
	choice_2.text = ""
	choice_3.text = ""

func _show_choices() -> void:
	choice_1.text = choices[0]["text"]
	choice_2.text = choices[1]["text"]
	choice_3.text = choices[2]["text"]
	animation_player.play("show_choices")

func _on_choice_selected():
	stop()
	choices_finished.emit(choice_selected_index)
	
func start(choices_data: Array) -> void:
	choices = choices_data
	is_running = true
	state = State.IDLE

func stop():
	is_running = false
	state = State.IDLE
	_hide_ui()
