class_name QuestCheckpoint extends Resource

@export var quest_checkpoint_id: String
@export var quest_checkpoint_name: String
@export var points: int = 1
@export var completed: bool = false
@export var completed_at: String

signal completed_checkpoint

func complete():
	completed = true
	completed_at = Time.get_datetime_string_from_system()
	completed_checkpoint.emit()

func save():
	var data = {
		"quest_checkpoint_id": quest_checkpoint_id,
		"quest_checkpoint_name": quest_checkpoint_name,
		"completed": completed,
		"completed_at": completed_at,
		"points": points
	}
	return data

func restore(data):
	if data.has("quest_checkpoint_id"):
		quest_checkpoint_id = data["quest_checkpoint_id"]
	if data.has("quest_checkpoint_name"):
		quest_checkpoint_name = data["quest_checkpoint_name"]
	if data.has("completed"):
		completed = data["completed"]
	if data.has("completed_at"):
		completed_at = data["completed_at"]
	if data.has("points"):
		points = data["points"]
