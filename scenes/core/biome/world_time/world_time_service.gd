extends Node

@export var INGAME_SPEED: float = 1.0
@export var INITIAL_HOUR: int = 12:
	set(value):
		INITIAL_HOUR = value
		time = INGAME_TO_REAL_MINUTE_DURATION * INITIAL_HOUR * MINUTES_PER_HOUR

const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY

var time: float = 0.0
var past_minute: float = -1.0
var current_value: float = 0.0
var time_elapsed: float = 0.0

signal time_tick(day: int, hour: int, minute: int)

func _ready() -> void:
	time = INGAME_TO_REAL_MINUTE_DURATION * INITIAL_HOUR * MINUTES_PER_HOUR

func _process(delta: float) -> void:
	time += delta * INGAME_TO_REAL_MINUTE_DURATION * INGAME_SPEED
	time_elapsed += delta
	current_value = (sin(time - PI / 2.0) + 1.0) / 2.0
	_recalculate_time()

func _recalculate_time() -> void:
	var total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)
	@warning_ignore("integer_division")
	var day = int(total_minutes / MINUTES_PER_DAY)
	var current_day_minutes = total_minutes % MINUTES_PER_DAY
	@warning_ignore("integer_division")
	var hour = int(current_day_minutes / MINUTES_PER_HOUR)
	var minute = int(current_day_minutes % MINUTES_PER_HOUR)

	if past_minute != minute:
		past_minute = minute
	time_tick.emit(day, hour, minute)

func get_current_time_string() -> String:
	var total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)
	var current_day_minutes = total_minutes % MINUTES_PER_DAY
	@warning_ignore("integer_division")
	var hour = int(current_day_minutes / MINUTES_PER_HOUR)
	var minute = int(current_day_minutes % MINUTES_PER_HOUR)
	
	var period = "AM" if hour < 12 else "PM"
	var hour_12 = hour % 12
	if hour_12 == 0:
		hour_12 = 12
	
	return "%02d:%02d %s" % [hour_12, minute, period]
