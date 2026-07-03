extends Node

var quests = {}

func set_quest_status(quest_id: String, status: String) -> void:
	quests[quest_id] = status

func get_quest_status(quest_id: String) -> String:
	return quests.get(quest_id, "inactive")
