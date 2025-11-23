class_name Quest extends Resource

@export var quest_group: String
@export var quest_id: String
@export var quest_name: String
@export var quest_description: String
@export var quest_status: QuestStatus
@export var quest_checkpoints: Array[QuestCheckpoint]

signal quest_status_changed(status: QuestStatus)

enum QuestStatus {
	NONE,
	AVAILABLE,
	IN_PROGRESS,
	COMPLETED,
	FAILED
}

func update_quest_status(status: Quest.QuestStatus):
	quest_status = status
	quest_status_changed.emit(quest_status)

func start_quest():
	update_quest_status(Quest.QuestStatus.IN_PROGRESS)
	
func complete_quest():
	update_quest_status(Quest.QuestStatus.COMPLETED)

func fail_quest():
	update_quest_status(Quest.QuestStatus.FAILED)

func complete_checkpoint(checkpoint_id: String):
	for checkpoint in quest_checkpoints:
		if checkpoint.quest_checkpoint_id == checkpoint_id:
			checkpoint.complete()

func has_completed_quest():
	for checkpoint in quest_checkpoints:
		if not checkpoint.completed:
			return false
	return true

func has_completed_checkpoint(checkpoint_id: String):
	for checkpoint in quest_checkpoints:
		if checkpoint.quest_checkpoint_id == checkpoint_id:
			return checkpoint.completed
	return false

func save():
	var data = {
		"quest_group": quest_group,
		"quest_id": quest_id,
		"quest_name": quest_name,
		"quest_description": quest_description,
		"quest_status": quest_status,
		"quest_checkpoints": quest_checkpoints
	}
	return data

func restore(data):
	if data.has("quest_group"):
		quest_group = data["quest_group"]
	if data.has("quest_id"):
		quest_id = data["quest_id"]
	if data.has("quest_name"):
		quest_name = data["quest_name"]
	if data.has("quest_description"):
		quest_description = data["quest_description"]
	if data.has("quest_status"):
		match data["quest_status"].to_upper():
			"NONE":
				quest_status = Quest.QuestStatus.NONE
			"AVAILABLE":
				quest_status = Quest.QuestStatus.AVAILABLE
			"IN_PROGRESS":
				quest_status = Quest.QuestStatus.IN_PROGRESS
			"COMPLETED":
				quest_status = Quest.QuestStatus.COMPLETED
			"FAILED":
				quest_status = Quest.QuestStatus.FAILED
	if data.has("quest_checkpoints"):
		quest_checkpoints = []
		for checkpoint_data in data["quest_checkpoints"]:
			var checkpoint = QuestCheckpoint.new()
			checkpoint.restore(checkpoint_data)
			quest_checkpoints.append(checkpoint)
