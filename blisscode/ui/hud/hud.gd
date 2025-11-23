class_name HUD extends Node2D

@export var seconds_label: Label
@export var current_time_label: Label
@export var enemies_label: Label
@export var animation_player: AnimationPlayer

func _ready() -> void:
	WorldTimeService.time_tick.connect(_on_time_tick)
	if current_time_label:
		current_time_label.text = WorldTimeService.get_current_time_string()

func _on_time_tick(_day: int, _hour: int, _minute: int) -> void:
	if current_time_label:
		current_time_label.text = WorldTimeService.get_current_time_string()

#func _on_enemies_killed(count: int, max_count: int) -> void:
	#enemies_label.text = "%d/%d" % [count, max_count]

func _process(_delta: float) -> void:
	if seconds_label:
		seconds_label.text = "%.2f" % (WorldTimeService.time_elapsed)
	if current_time_label:
		current_time_label.text = WorldTimeService.get_current_time_string()
		
func show_hud():
	animation_player.play("transition_in")
	
func hide_hud():
	animation_player.play("transition_out")
