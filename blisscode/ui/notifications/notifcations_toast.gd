extends CanvasLayer

@export var title_label: Label
@export var description_label: Label
@export var time_label: Label
@export var animation_player: AnimationPlayer
@export var close_texture_button: TextureButton

var notification_queue = []
var is_showing = false

func _ready():
	close_texture_button.pressed.connect(hide_notification)

func _process(_delta):
	if not is_showing and notification_queue.size() > 0:
		set_notification(notification_queue.pop_front())

func _on_close_texture_button_pressed():
	hide_notification()

func show_notification(title: String, description: String):
	notification_queue.append({
		"title": title, 
		"description": description
	})
	
func set_notification(data):
	is_showing = true
	title_label.text = data["title"]
	description_label.text = data["description"]
	time_label.text = Time.get_datetime_string_from_system()
	animation_player.play("show")
	await animation_player.animation_finished
	await get_tree().create_timer(5.0).timeout
	hide_notification()

func hide_notification():
	animation_player.play("hide")
	await animation_player.animation_finished
	is_showing = false
